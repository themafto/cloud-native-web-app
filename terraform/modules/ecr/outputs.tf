output "frontend_url" {
  value = aws_ecr_repository.frontend_repo
}
output "rds_url" {
  value = aws_ecr_repository.rds_repo
}
output "redis_url" {
  value = aws_ecr_repository.redis_repo
}