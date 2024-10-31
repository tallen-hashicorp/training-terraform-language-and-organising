# Configure the Terraform version and provider requirements
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Define the AWS provider, which specifies the region to use
provider "aws" {
  region = var.aws_region
}

# Define local values for reusable variables
locals {
  # Instance type to launch
  instance_type = "t2.micro"

  # Using the ID from the latest Ubuntu AMI data source (defined below)
  ami_id = data.aws_ami.ubuntu.id
}

# Use a VPC module to create a Virtual Private Cloud and subnets
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  # Basic configuration for the VPC
  name = "terraform-tutorial-vpc"
  cidr = var.vpc_cidr

  # Availability zones and subnet configurations
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  # Enable NAT gateway to allow private instances access to the internet
  enable_nat_gateway = true
}

# Fetch the latest Ubuntu 20.04 AMI (Amazon Machine Image)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical's AWS account ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Create an EC2 instance using the AMI from the data source and instance type from locals
resource "aws_instance" "example" {
  ami           = local.ami_id
  instance_type = local.instance_type
  subnet_id     = module.vpc.public_subnets[0]  # Launch in one of the public subnets

  tags = {
    Name = "Terraform Tutorial Instance"
  }
}
