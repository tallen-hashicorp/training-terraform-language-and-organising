# training-terraform-language-and-organising
Terraform language &amp; organising your Terraform code. Terraform code is based on the HCL2 toolkit. HCL stands for HashiCorp Configuration Language. Terraform code, is a declarative language that is specifically designed for provisioning infrastructure on any cloud or platform. Its Human and machine readable and Written as HashiCorp Configuration Language (HCL)

## Terraform Syntax - Blocks
* Blocks contain content
* A block body is delineated by { }
* A block starts with a keyword such as:
    * resource
    * variable
    * output
    * data

```hcl
resource "aws_instance" "example_ec2_instance" {
 ami               = "ami-09ee0944866c73f62"
 instance_type     = "t2.micro"
 availability_zone = "eu-west-2b"

 network_interface {
   network_interface_id = aws_network_interface.ec2_public_target_ni.id
   device_index         = 0
 }
 tags = {
   Name         = "nomura-dev"
 }
}
```

## Top Level Keywords
* terraform
* provider
* resource
* variable
* output
* module
* data
* locals

## terraform{}
Terraform settings are gathered together into terraform blocks. Each terraform block can contain a number of settings related to Terraform's behavior.

```hcl
terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = ">=5.31.0"
   }
 }
}
provider "aws" {
 region = "eu-west-2"
}
```

## providers{}
Terraform relies on plugins called providers to interact with cloud providers, SaaS providers, and other APIs. Terraform configurations must declare what providers they require so that Terraform can install and use them
```hcl
terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "5.52.0"
   }
 }
}

provider "aws" {
  region = var.aws_region
}
```

## resource{} Naming
In Terraform, careful consideration of resource naming is crucial for clarity and maintainability. While Terraform itself doesn't enforce naming conventions, adopting a consistent and descriptive approach helps prevent naming conflicts and promotes better collaboration among team members.

```hcl
resource "docker_container" "nginx" {
 image = docker_image.nginx.image_id
 name  = "nomura-container-name"
 ports {
   internal = 80
   external = 8000
 }
}
```

## module{}
In Terraform, modules are used to package and reuse configurations, enabling you to include external sets of Terraform files within your projects.
```hcl
module "sandbox-build" {
 source  = "app.terraform.io/danny-hashicorp/sandbox-build/aws"
 version = "1.0.0"

 vpc_cidr          = "172.31.0.0/16"
 subnet_cidr       = "172.31.32.0/20"
 availability_zone = "eu-west-2b"

 ami_id        = "ami-00785f4835c6acf64"
 instance_type = "t2.small"
 instance_tags = {
   Name        = "dev-vm"
 }
}
```

## data{}
Data sources allow data to be fetched or computed for use elsewhere in Terraform configuration
```hcl
data "aws_ami" "ubuntu" {
 most_recent = true

 filter {
   name   = "name"
   values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
 }
 owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
 ami           = data.aws_ami.ubuntu.id
 instance_type = "t3.micro"
}
```

## locals{}
Locals in Terraform are used to define and reuse values within a single configuration file, enhancing readability and reducing redundancy by encapsulating logic and values that are specific to that configuration context.

```hcl
locals {
 instance_type        = "t2.micro"
 ami_id               = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS
 availability_zones   = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
 tags                 = {
   Name        = "ExampleInstance"
 }
}

resource "aws_instance" "demo" {
 ami           = local.ami_id
 instance_type = local.instance_type
 availability_zone = local.availability_zones[0]  # Using the first availability zone
 tags = local.tags
}
```

## Comments
Line Comments begin with a hash symbol: #
```hcl
# This is a line comment.
```

Block comments are contained between /* and */ symbols.
```hcl
/* This is a block comment.
Block comments can span multiple lines.
The comment ends with this symbol: */
```

## String Interpolation
A ${ ... } sequence is an interpolation, which evaluates the expression given between the markers, converts the result to a string if necessary, and then inserts it into the final string
```hcl
variable "environment" {
 type    = string
 default = "production"
}

resource "aws_instance" "my_resource" {
  tags = {
  Name = "app-${var.environment}-server"
  }
}
```

## Dependency Mapping - Implicit
Terraform can automatically keep track of dependencies for you. Look at the two resources below. Note the highlighted line in the aws_route_table resource. This is how we tell one resource to refer to another in terraform.

```hcl
resource "aws_internet_gateway" "demo_ig" {
 vpc_id = aws_vpc.demo_vpc.id
 tags = {
   Name = "demo-igw"
 }
}

resource "aws_route_table" "boundary_db_demo_rt" {
 vpc_id = aws_vpc.demo_vpc.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.demo_ig.id
 }
}
```

## Dependency Mapping - Explicit (`depends_on`)
In Terraform, implicit dependencies are automatically inferred based on resource references, streamlining the order of resource creation or updates. Explicit dependencies are declared using the depends_on attribute, offering finer control when relationships between resources are non-obvious or when custom workflows are required.

```hcl
resource "aws_vpc" "main" {
 provider   = aws.us_west_2
 cidr_block = "10.0.0.0/16"
}

resource "aws_s3_bucket" "bucket" {
 provider = aws.eu_west_2
 bucket   = "my-unique-bucket-name-terraform-example"
 acl      = "private"

 depends_on = [aws_vpc.main]  # Explicit depends_on statement
}
```

## File Structure
Terraform files always end in either a *.tf or *.tfvars extension
* `main.tf` - Functional code, The first file is called main.tf. This is where you normally store your Terraform code. With larger, more complex infrastructure, you might break this up across several files
* `variables.tf` - Variables required by the functional code, By convention, Terraform variables are placed in a file called variables.tf. Variables can have default settings. 
* `outputs.tf` - Information displayed at the end of the Terraform run. The outputs file is where you configure any message or data you want to show at the end of a terraform apply.

## Using Variables
Variables allow you to parameterize your configurations, enabling flexibility and reuse by defining values that can be easily modified or passed externally.

```hcl
variable "aws_subnet_cidr" {
 type    = string
 default = "172.31.32.0/24"
}

variable "availability_zone" {
 type    = string
 default = "eu-west-2b"
}

resource "aws_subnet" "demo_subnet" {
 vpc_id                  = aws_vpc.demo_vpc.id
 cidr_block              = var.aws_subnet_cidr
 map_public_ip_on_launch = true
 availability_zone       = var.availability_zone
}
```

### How are Variables Set?
Once you have some variables defined, you can set and override them in different ways. Terraform loads variables in the following order, with later sources taking precedence over earlier ones:

1. Environment variable - part of your shell environment
2. User manual entry or set in a file which is not variables.tf
3. Configuration file - set in your variables.tf file
4. Configuration file - set in your terraform.tfvars file
5. Command line flag - run as a command line switch -var and -var-file

### Exported Environment Variables
Allows you to specify values for variables outside of the Terraform code
```hcl
export TF_VAR_server_count=4
export TF_VAR_server_type="dev"
export TF_VAR_image_list='["ami-123", "ami-456", "ami-789"]'
```

### Automatically
Terraform will automatically load a file named terraform.tfvars, if present in the current directory

```bash
terraform-101 % cat terraform.tfvars 
server_count=5
server_type="dev"
image_list=["ami-abc", "ami-def", "ami-ghi"]%

—-------------------------------------------------------------------

# Exclude all .tfvars files, which are likely to contain sensitive data, such as
# password, private keys, and other secrets. These should not be part of version
# control as they are data points which are potentially sensitive and subject
# to change depending on the environment.
*.tfvars
*.tfvars.json
```

### Explicitly Through Command Line Flags
Each Variable needs to be specified through the `-var` flag

```bash
terraform plan -var="server_count=6" \
                -var="server_type=prod" \
                -var='image_list=["ami-jkl", "ami-mno", "ami-pqr"]
```