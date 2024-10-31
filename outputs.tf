# Output the public IP address of the created EC2 instance
output "instance_public_ip" {
  description = "Public IP address of the example instance"
  value       = aws_instance.example.public_ip
}

# Output the ID of the VPC created by the module
output "vpc_id" {
  description = "ID of the VPC created in the module"
  value       = module.vpc.vpc_id
}
