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
