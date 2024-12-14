output "url_rds" {
  value = aws_ecr_repository.rds.repository_url
}
output "url_redis" {
  value = aws_ecr_repository.redis.repository_url
}