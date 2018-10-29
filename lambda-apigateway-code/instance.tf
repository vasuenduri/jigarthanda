provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_access_key}"
  region     = "${var.region}"
}

data "aws_vpc" "default_vpc" {
  id = "${var.vpc_id}"
}

resource "aws_security_group" "instance_group" {
  name        = "${var.security_group_name}"
  description = "Testing the Lambda ApiGateway Integration"
  vpc_id      = "${data.aws_vpc.default_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.default_vpc.cidr_block}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.security_group_name}"
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.rds_db_name}"

  engine            = "mysql"
  engine_version    = "8.0.11"
  instance_class    = "db.t2.micro"
  allocated_storage = 10
  option_group_name = "default:mysql-8-0"
  auto_minor_version_upgrade = false

  name     = "collections"
  username = "${var.rds_db_username}"
  password = "${var.rds_db_password}"
  port     = "3306"

  vpc_security_group_ids = ["${aws_security_group.instance_group.id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = {
    Name       = "${var.rds_db_name}"
    Environment = "staging"
  }

  # DB subnet group
  db_subnet_group_name = "${var.rds_db_subnet_group_name}"

  # DB parameter group
  parameter_group_name = "default.mysql8.0"

  parameters = [
    { 
      name = "character_set_client"
      value = "utf8"
    },
    { 
      name = "character_set_server"
      value = "utf8"
    }
  ]
}

resource "aws_s3_bucket" "testing-s3" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"
  region = "${var.region}"

  tags {
    Name        = "${var.s3_bucket_name}"
  }
 depends_on = ["module.db"]
}

resource "null_resource" "remove" {
 triggers {
    s3_bucket_id = "${aws_s3_bucket.testing-s3.id}"
    rds_db_id = "${module.db.this_db_instance_address}"
  }
 provisioner "local-exec" {
   command = "rm -rf vars.py"
 }
depends_on = ["aws_s3_bucket.testing-s3"]
}

resource "null_resource" "detail" {
 triggers {
    s3_bucket_id = "${aws_s3_bucket.testing-s3.id}"
    rds_db_id = "${module.db.this_db_instance_address}"
  }
 provisioner "local-exec" {
    command = <<EOT
      echo rds_host =  \"${module.db.this_db_instance_address}\" >> vars.py;
      echo rds_username = \"${var.rds_db_username}\" >> vars.py;
      echo rds_password = \"${var.rds_db_password}\" >> vars.py;
      echo rds_database = \"${module.db.this_db_instance_name}\" >> vars.py
      echo bucket_name = \"${var.s3_bucket_name}\" >> vars.py
   EOT
 }
 depends_on = ["null_resource.remove"]
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "devops-lambda-gateway-testing-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
depends_on = ["null_resource.detail"]
}

resource "aws_iam_policy" "s3_put_object" {
  name = "devops-lambda-apigateway-testing-s3-policy"
  path = "/"
  description = "For Testing Purpose"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::${var.s3_bucket_name}/*"]
    }
  ]
}
EOF
depends_on = ["aws_iam_role.lambda_execution_role"]
}

data "aws_iam_policy" "vpc_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3-attach" {
    role       = "${aws_iam_role.lambda_execution_role.name}"
    policy_arn = "${aws_iam_policy.s3_put_object.arn}"
    depends_on = ["aws_iam_role.lambda_execution_role"]
}

resource "aws_iam_role_policy_attachment" "vpc-execution-attach" {
    role       = "${aws_iam_role.lambda_execution_role.name}"
    policy_arn = "${data.aws_iam_policy.vpc_execution.arn}"
    depends_on = ["aws_iam_role.lambda_execution_role"]
}

resource "null_resource" "creatingzipfile" {
 triggers {
    s3_bucket_id = "${aws_s3_bucket.testing-s3.id}"
    rds_db_id = "${module.db.this_db_instance_address}"
  }
 provisioner "local-exec" {
    command = <<EOT
      rm -rf ${path.cwd}/whatask/devops-lambda-gateway-testing.zip;
      cp -rf ${path.cwd}/vars.py ${path.cwd}/whatask/;
      cd ${path.cwd}/whatask;zip -r devops-lambda-gateway-testing.zip *;
      cd ../
   EOT
 }
 depends_on = ["null_resource.detail"]
}

resource "aws_lambda_function" "test_lambda" {
  filename         = "${path.cwd}/whatask/devops-lambda-gateway-testing.zip"
  function_name    = "${var.lambda_function_name}"
  role             = "${aws_iam_role.lambda_execution_role.arn}"
  handler          = "main.lambda_handler"
  runtime          = "python2.7"
  timeout = 90
  vpc_config {
    subnet_ids         = ["${var.subnet_id}"]
    security_group_ids = ["${aws_security_group.instance_group.id}"]
  }
  depends_on = ["aws_iam_role_policy_attachment.vpc-execution-attach", "null_resource.creatingzipfile"]
}

resource "aws_api_gateway_rest_api" "testing_api" {
  name        = "${var.api_gateway_name}"
  description = "Terraform Serverless Application Example"
  depends_on = ["aws_lambda_function.test_lambda"]
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.testing_api.root_resource_id}"
  path_part   = "images"
  depends_on = ["aws_api_gateway_rest_api.testing_api"]
}



resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.testing_api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "POST"
  authorization = "NONE"
 depends_on = ["aws_api_gateway_resource.proxy"]
}



resource "aws_api_gateway_integration" "lambda_images" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.test_lambda.invoke_arn}"
  depends_on = ["aws_api_gateway_method.proxy"]
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"
  status_code = "200"
  depends_on = ["aws_api_gateway_method.proxy"]
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
  depends_on = ["aws_api_gateway_method.proxy"]
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    "aws_api_gateway_integration.lambda_images"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.testing_api.id}"
  stage_name  = "test"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test_lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.testing_api.execution_arn}/*/*/*"
  depends_on = ["aws_api_gateway_deployment.example"]
}

output "base_url" {
  value = "${aws_api_gateway_deployment.example.invoke_url}"
}
output "instance_records" {
 value = "${data.aws_vpc.default_vpc.cidr_block}"
}


output "rds_db_instance_username" {
  description = "The master username for the database"
  value       = "${var.rds_db_username}"
}


output "rds_db_instance_name" {
  description = "The database name"
  value       = "${module.db.this_db_instance_name}"
}

output "rds_db_instance_address" {
  description = "The address of the RDS instance"
  value       = "${module.db.this_db_instance_address}"
}
