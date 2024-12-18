terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "my-terraform-state-bucket-32432"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}



module "vpc" {
  source = "./modules/vpc"

  region                 = var.region
  dns_zone_id            = var.dns_zone_id
  acm_certificate_ssl    = var.acm_certificate_ssl
  cloudfront_domain_name = module.s3.cloudfront_domain_name
  dns_zone_id_cloudfront = var.dns_zone_id_cloudfront
}
module "ecr" {
  source = "./modules/ecr"
}
module "s3" {
  source                 = "./modules/s3_cloudfront"
  region                 = var.region
  vpc_endpoint_id        = module.vpc.vpc_endpoint_id
  acm_certificate_ssl_us = var.acm_certificate_ssl_us
}

module "rds" {
  source = "./modules/rds"

  db_instance_class     = var.db_instance_class
  db_name               = var.db_name
  db_password           = var.db_password
  db_username           = var.db_username
  rds_security_group_id = module.vpc.rds_security_group_id
  db_subnet_group_name  = module.vpc.db_subnet_group_name
}
module "elasticache" {
  source = "./modules/elasticache"

  private_subnets_1_ids = module.vpc.private_subnet_a_id
  private_subnets_2_ids = module.vpc.private_subnet_b_id
  redis_sg              = module.vpc.redis_security_group_id
}
module "ecs" {
  source = "./modules/ecs"

  db_name                          = var.db_name
  db_password                      = var.db_password
  db_username                      = var.db_username
  rds_endpoint                     = module.rds.rds_endpoint
  aws_lb_target_group_rds_tg_arn   = module.vpc.aws_lb_target_group_rds_tg
  private_subnet_a_id              = module.vpc.private_subnet_a_id
  private_subnet_b_id              = module.vpc.private_subnet_b_id
  rds_security_group_id            = module.vpc.rds_security_group_id
  rds_id                           = module.rds.rds_id
  main_domain                      = var.main_domain
  sub1_domain                      = var.sub1_domain
  sub2_domain                      = var.sub2_domain
  aws_lb_target_group_redis_tg_arn = module.vpc.aws_lb_target_group_redis_tg
  redis_security_group_id          = module.vpc.redis_security_group_id
  rds_repository                   = var.rds_repo
  redis_endpoint_host              = module.elasticache.elasticache_endpoint
  redis_repository                 = var.redis_repo
}

