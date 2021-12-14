//variable "aws_region" {
//  type = string
//  description = "AWS Region to create the cluster"
//  default = "eu-west-1"
//}
//
//variable "aws_profile" {
//  type = string
//  description = "AWS Profile to execute Terraform actions"
//  default = "paradigma"
//}

variable "eks_cluster_name" {
  type = string
  description = "EKS cluster name"
  default = "from0tocloud-eks-cluster-tf"
}

variable "eks_cluster_version" {
  type = string
  description = "EKS cluster version"
  default = "1.21"
}

variable "eks_workers_instance_types" {
  description = "Workers instance types"
  type        = list(string)
  default     = ["t2.micro"]
}
