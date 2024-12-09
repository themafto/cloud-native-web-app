variable "ecr_repo_name" {
  description = "ECR front Name"
  type        = string
}
variable "ecr_rds_name" {
  description = "ECR rds Name"
  type        = string
}
variable "ecr_redis_name" {
  description = "ECR redis Name"
  type        = string
}
variable "region" {
  description = "AWS region name"
}