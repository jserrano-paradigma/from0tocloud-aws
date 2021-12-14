terraform {

  // S3 bucket data is not supported to variables because the bucket stores the state of the cluster and this data
  // should not be changed to prevent inconsistencies
  backend "s3" {
    bucket  = "from0tocloud-terraform-state"
    key     = "terraform.tfstate"
    region  = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "./modules/platform/vpc"
  eks_cluster_name = var.eks_cluster_name
}

module "eks" {
  source = "./modules/platform/eks"
  eks_cluster_name = var.eks_cluster_name
  eks_cluster_version = var.eks_cluster_version
  eks_workers_instance_types = var.eks_workers_instance_types

  vpc_id = module.vpc.id
  vpc_private_subnets = module.vpc.private_subnets

}

