data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.22.0"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  subnets         = var.vpc_private_subnets
  vpc_id          = var.vpc_id
  manage_aws_auth = false

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
    additional_tags = {
      app = "from0tocloud"
    }
  }

  node_groups = {
    realtime_eks_workers = {
      name = "${var.eks_cluster_name}_eks_workers"
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 2

      instance_types = var.eks_workers_instance_types
      k8s_labels = {
        Environment = "dev"
      }

    }
  }
}
