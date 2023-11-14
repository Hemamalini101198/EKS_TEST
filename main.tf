terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.25.0"
    }
  }
}
provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source       = "./Modules/vpc"
  vpc_name     = var.vpc_name
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  vpc_cidr = var.vpc_cidr
  vpc_tags = var.vpc_tags
}

module "eks_cluster" {
  source          = "./Modules/EKS-cluster"
  cluster_name    = var.cluster_name
  private_subnets = var.private_subnets
  subnets = var.private_subnets
  managed_node_desired_size = var.managed_node_desired_size
  managed_node_min_size     = var.managed_node_min_size
  managed_node_max_size     = var.managed_node_max_size
  node_capacity_type  = var.node_capacity_type
  node_instance_type = var.node_instance_type
  depends_on = [ module.vpc ]
}

module "alb" {
  source = "./Modules/alb"
  alb_name = var.alb_name
  alb_tag_name = var.alb_tag_name
  acm_certificate_arn = ""
  depends_on = [ module.vpc , module.eks_cluster ]
}


module "asg" {
  source      = "./Modules/asg"
  asg_names = var.asg_name
  asg_name = var.asg_name
  ami_id = var.ami_id
  node_capacity_type = var.node_capacity_type
  min_size = var.managed_node_min_size
  max_size = var.managed_node_max_size
  desired_capacity = var.managed_node_desired_size
  vpc_zone_identifiers = var.private_subnets
  depends_on = [ module.vpc, module.eks_cluster ]
}

/*
module "acm" {
  source   = "./Modules/acm"
  cert_domains = ["var.domain_names"]  
}
*/