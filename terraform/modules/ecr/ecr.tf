resource "aws_ecr_repository" "frontend_repo" {
  name = var.ecr_repo_name
}
resource "aws_ecr_repository" "rds_repo" {
  name = var.ecr_rds_name
}
resource "aws_ecr_repository" "redis_repo" {
  name = var.ecr_redis_name
}