#!/bin/bash
set -e

export CLUSTER_NAME="from0tocloud-eks-cluster-tf"

executeTerraform() {
  terraform init
  terraform plan -var="eks_cluster_name=$CLUSTER_NAME"
  terraform apply -auto-approve -var="eks_cluster_name=$CLUSTER_NAME"
}

executeTerraform
