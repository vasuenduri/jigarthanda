variable "vpc_id" {
description = "Please provide the VPC ID"
}

variable "subnet_id" {
description = "Please provide the Private Subnet ID"
}

variable "access_key" {
description = "Please provide the access key"
}

variable "secret_access_key" {
description = "Please provide the secret access key"
}

variable "region" {
description = "Please provide the region name"
}

variable "security_group_name" {
description = "please provide the name for the security group creation"
default = "devops-lambda-apigateway-testing-sg"
}

variable "rds_db_name" {
description = "Please provide the rds database name"
default = "devops-lambda-apigateway-testing-rds"
}

variable "rds_db_username" {
description = "Please provide the rds database username"
}

variable "rds_db_password" {
description = "Please provide the rds databse password"
}

variable "rds_db_subnet_group_name" {
description = "This script assumes you already have a rds subnet group name if not please create one with private subnets and provide the name here"
}

variable "s3_bucket_name" {
description = "Please provide the name for the s3 bucket creation"
default = "devops-lambda-apigateway-testing-s3"
}

variable "lambda_function_name" {
description = "Please provide the name for the lambda function"
default = "devops-lambda-apigateway-testing-lambda"
}

variable "api_gateway_name" {
description = "Please provide the name for the REST Api Gateway"
default = "devops-lambda-apigateway-testing-api"
}
