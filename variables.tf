# Define the AWS region as a configurable variable with a default value
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

# Define the CIDR block for the VPC, allowing customization through .tfvars
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Define the number of EC2 instances to launch
variable "instance_count" {
  description = "Number of EC2 instances to launch"
  type        = number
  default     = 1
}