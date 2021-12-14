output "vpc_id" {
  value = module.vpc.id
}

output "cluster_id" {
  value = module.eks.cluster_id
}
