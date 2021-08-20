locals {
  # The usage of the specific kubernetes.io/cluster/* resource tags below are required
  # for EKS and Kubernetes to discover and manage networking resources
  # https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#base-vpc-networking
  tags = merge(module.label.tags, map("kubernetes.io/cluster/${module.label.id}", "shared"))
}


module "label" {
  source = "./modules/label"

  tags       = var.tags
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, list("cluster")))
}

module "vpc" {
  source = "./modules/vpc/"

  tags       = local.tags
  namespace  = module.label.namespace
  name       = module.label.name
  stage      = module.label.stage
  cidr_block = var.cidr_block
}

module "subnets" {
  source = "./modules/subnets"

  availability_zones  = var.availability_zones
  namespace           = module.label.namespace
  stage               = module.label.stage
  name                = module.label.name
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.vpc.igw_id
  cidr_block          = module.vpc.vpc_cidr_block
  nat_gateway_enabled = true
  tags                = local.tags
}

module "eks_workers" {
  source = "./modules/eks-workers"

  namespace                          = module.label.namespace
  stage                              = module.label.stage
  name                               = module.label.name
  attributes                         = var.attributes
  instance_type                      = var.instance_type
  vpc_id                             = module.vpc.vpc_id
  subnet_ids                         = module.subnets.private_subnet_ids
  associate_public_ip_address        = var.associate_public_ip_address
  health_check_type                  = var.health_check_type
  min_size                           = var.min_size
  max_size                           = var.max_size
  wait_for_capacity_timeout          = var.wait_for_capacity_timeout
  cluster_name                       = module.label.id
  cluster_endpoint                   = module.eks_cluster.eks_cluster_endpoint
  cluster_certificate_authority_data = module.eks_cluster.eks_cluster_certificate_authority_data
  cluster_security_group_id          = module.eks_cluster.security_group_id
  use_custom_image_id                = var.use_custom_image_id
  image_id                           = var.image_id

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = var.autoscaling_policies_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent
  tags                                   = module.label.tags

  # Bastion configuration
  allow_bastion_ingress     = true
  bastion_security_group_id = module.bastion_hosts.bastion_security_group_id
}


module "eks_cluster" {
  source = "./modules/eks-cluster"

  stage              = module.label.stage
  namespace          = module.label.namespace
  name               = module.label.name
  attributes         = var.attributes
  region             = var.region
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.subnets.public_subnet_ids
  kubernetes_version = var.kubernetes_version

  # `workers_security_group_count` is needed to prevent `count can't be computed` errors
  workers_security_group_ids = [
  module.eks_workers.security_group_id]
  workers_security_group_count = 1

  workers_role_arns      = [module.eks_workers.workers_role_arn]
  bastion_host_role_arns = [module.bastion_hosts.bastion_host_role_arn]
  kubeconfig_path        = var.kubeconfig_path
  tags                   = module.label.tags
}

module "aws_ingress_controller" {
  source = "./modules/aws-ingress-controller"

  kubeconfig_path   = var.kubeconfig_path
  tags              = module.label.tags
  name              = module.label.name
  stage             = module.label.stage
  namespace         = module.label.namespace
  attributes        = module.label.attributes
  cluster_name      = module.eks_cluster.eks_cluster_id
  vpc_id            = module.vpc.vpc_id
  region            = var.region
  workers_role_arn  = module.eks_workers.workers_role_arn
  workers_role_name = module.eks_workers.workers_role_name
}


module "external-dns" {
  source = "./modules/external-dns"

  tags              = module.label.tags
  name              = module.label.name
  stage             = module.label.stage
  namespace         = module.label.namespace
  attributes        = module.label.attributes
  workers_role_name = module.eks_workers.workers_role_name
}


module "ecr" {
  source = "./modules/ecr"

  name       = module.label.name
  stage      = module.label.stage
  namespace  = module.label.namespace
  attributes = var.attributes
}

module "bastion_hosts" {
  source = "./modules/bastion"

  tags       = module.label.tags
  name       = module.label.name
  stage      = module.label.stage
  namespace  = module.label.namespace
  attributes = module.label.attributes

  cluster_name                = module.eks_cluster.eks_cluster_id
  instance_type               = var.bastion_instance_type
  subnet_ids                  = module.subnets.public_subnet_ids
  region                      = var.region
  vpc_id                      = module.vpc.vpc_id
  destination_security_groups = [module.eks_workers.security_group_id]
  ami_id                      = var.ami_id

  min_size         = 0
  max_size         = 2
  desired_capacity = 1
}
