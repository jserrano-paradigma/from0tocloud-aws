output "id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "VPC ID"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "VPC Private Subnets"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "VPC Public Subnets"
}

output "security_group" {
  description = "Security Group"
  value       = aws_security_group.eks_instance_security_group.id
}
