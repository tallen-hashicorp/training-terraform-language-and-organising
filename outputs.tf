# Output the private IP address of the created EC2 instance
output "instance_private_ip" {
  description = "Public IP address of the example instance"
  value       = [for instance in aws_instance.example : instance.private_ip]
}

# Output the ID of the VPC created by the module
output "vpc_id" {
  description = "ID of the VPC created in the module"
  value       = module.vpc.vpc_id
}
