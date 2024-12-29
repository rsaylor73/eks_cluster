# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.6"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  cluster_endpoint_public_access           = true
  create_kms_key              = false
  create_cloudwatch_log_group = false
  cluster_encryption_config = {}

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = var.csi_iam_role_arn
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = var.ami_type
    instance_types = ["t3.medium"]

    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }

  eks_managed_node_groups = {
    one = {
      name = var.node_group1_name

      instance_types = [var.node_group1_instance_type]

      min_size     = var.node_group1_min_size
      max_size     = var.node_group1_max_size
      desired_size = var.node_group1_desired_size
    }
  }

  tags = {
    env       = var.env_name
  }
}
