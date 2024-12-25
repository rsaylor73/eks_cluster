module "vpc" {
  source = "./modules/vpc"
  cluster_name = var.cluster_name
  vpc_cidr = var.vpc_cidr
  private_subnets_cidr1 = var.private_subnets_cidr1
  private_subnets_cidr2 = var.private_subnets_cidr2
  private_subnets_cidr3 = var.private_subnets_cidr3
  public_subnet_cidr1 = var.public_subnet_cidr1
  public_subnet_cidr2 = var.public_subnet_cidr2
  public_subnet_cidr3 = var.public_subnet_cidr3
}

module "eks" {
  source = "./modules/eks"
  cluster_name = var.cluster_name
  vpc_cidr = var.vpc_cidr
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  ami_type = var.ami_type
  node_group1_desired_size = var.node_group1_desired_size
  node_group1_instance_type = var.node_group1_instance_type
  node_group1_max_size = var.node_group1_max_size
  node_group1_min_size = var.node_group1_min_size
  node_group1_name = var.node_group1_name
  node_group2_desired_size = var.node_group2_desired_size
  node_group2_instance_type = var.node_group2_instance_type
  node_group2_max_size = var.node_group2_max_size
  node_group2_min_size = var.node_group2_min_size
  node_group2_name = var.node_group2_name
  csi_iam_role_arn = module.csi.csi_iam_role_arn
}

module "csi" {
  source = "./modules/csi"
  cluster_name  = module.eks.cluster_name
  oidc_provider = module.eks.oidc_provider
}
