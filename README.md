# Terraform Training: Language and Code Organization

This guide introduces the fundamentals of Terraform, including the HCL (HashiCorp Configuration Language), syntax, and best practices for organizing Terraform code. Terraform’s declarative language is designed for provisioning infrastructure across any cloud or platform, offering both human and machine readability.

For a quick reference guide, I have put together this short [cheat sheet](./docs/cheatsheet.md).

---

## Table of Contents
1. [Terraform Syntax and Structure](#terraform-syntax-and-structure)
2. [Top-Level Keywords](#top-level-keywords)
3. [Detailed Block Explanations](#detailed-block-explanations)
4. [Comments in HCL](#comments-in-hcl)
5. [String Interpolation](#string-interpolation)
6. [Dependency Mapping](#dependency-mapping)
7. [File Structure and Usage](#file-structure-and-usage)
8. [Using Variables](#using-variables)

---

## Terraform Syntax and Structure
Terraform syntax relies on blocks to define configurations. Key components:
- **Blocks** contain settings, enclosed in `{ }`.
- **Keywords** like `resource`, `variable`, and `provider` start each block.

### Example Resource Block:
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
    Name = "nomura-dev"
  }
}
```

## Top-Level Keywords
Common keywords used in Terraform include:
- `terraform` - defines settings for Terraform’s behavior.
- `provider` - configures providers (e.g., AWS).
- `resource` - creates cloud resources.
- `variable` - defines input variables.
- `output` - specifies outputs.
- `module` - includes reusable configurations.
- `data` - retrieves data.
- `locals` - stores reusable values locally.

---

## Detailed Block Explanations

### `terraform{}` Block
The `terraform` block contains settings related to Terraform’s operations and behaviors.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.31.0"
    }
  }
}
```

### `provider{}` Block
Providers are plugins that enable Terraform to interact with various APIs and cloud providers. Providers are specified with their versions and configurations.

```hcl
provider "aws" {
  region = var.aws_region
}
```

### `resource{}` Block
Defines a cloud resource (like an AWS EC2 instance). Clear and consistent naming for resources is crucial for readability and collaboration.

```hcl
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "nginx-container"
  ports {
    internal = 80
    external = 8000
  }
}
```

### `module{}` Block
Modules are reusable sets of Terraform files, allowing you to package and share configurations.

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"
  name    = "my_vpc"
  cidr    = "10.0.0.0/16"
}
```

### `data{}` Block
Data sources allow data to be fetched or computed for use elsewhere in the configuration.

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}
```

### `locals{}` Block
Locals define reusable values within a configuration file.

```hcl
locals {
  instance_type  = "t2.micro"
  ami_id         = "ami-12345678"
  availability_zones = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}
```

## Comments in HCL
- **Line comments** start with `#`.
- **Block comments** are wrapped in `/* */`.

```hcl
# Line comment example
/* 
Block comment example
across multiple lines 
*/
```

## String Interpolation
String interpolation allows dynamic values to be injected into strings using `${...}` syntax.

```hcl
variable "environment" {
  type    = string
  default = "production"
}

resource "aws_instance" "app_server" {
  tags = {
    Name = "app-${var.environment}-server"
  }
}
```

## Dependency Mapping

### Implicit Dependencies
Terraform detects dependencies based on resource references, automatically ordering operations.

```hcl
resource "aws_internet_gateway" "demo_ig" {
  vpc_id = aws_vpc.demo_vpc.id
}

resource "aws_route_table" "demo_rt" {
  vpc_id = aws_vpc.demo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_ig.id
  }
}
```

### Explicit Dependencies (`depends_on`)
Use `depends_on` for specific dependencies when implicit dependencies aren’t enough.

```hcl
resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-unique-bucket-name"
  depends_on = [aws_vpc.main]
}
```

## File Structure and Usage
Organize Terraform files with `.tf` or `.tfvars` extensions:

- **`main.tf`** - Core functionality.
- **`variables.tf`** - Defines variables.
- **`outputs.tf`** - Specifies outputs.

---

## Using Variables
Variables enable flexibility and reuse by defining changeable values.

```hcl
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```

### Setting Variables
Variables can be set in:
1. **Environment variables**: `export TF_VAR_instance_type="t2.large"`
2. **Terraform files**: `variables.tf` or `terraform.tfvars`
3. **Command line**: `terraform plan -var="instance_type=t2.large"`
