import yaml
import sys

# Load the file into a data structure
with open(sys.argv[1], "r") as file:
    content = yaml.safe_load(file)

# Update the key you want to change
#content["spec"]["resources"]["requests"]["storage"] = sys.argv[2]
content["items"][0]["spec"]["template"]["spec"]["containers"][0]["image"] = sys.argv[2]

# Write the data structure back to your file in YAML
with open(sys.argv[1], "w") as file:
    yaml.safe_dump(content, file)
