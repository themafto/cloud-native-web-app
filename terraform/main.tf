terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = var.region
}
module "ecrRepo" {
  source = "./modules/ecr"

  ecr_repo_name = var.ecr_repo_name
  ecr_rds_name = var.ecr_rds_name
  ecr_redis_name = var.ecr_redis_name
}


module "vpc" {
  source = "./modules/vpc"
  region = var.region
}
module "s3" {
  source = "./modules/s3"
  region = var.region
  vpc_endpoint_id = module.vpc.vpc_endpoint_id
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
