output "rds_endpoint" {
  value = split(":", aws_db_instance.postgres.endpoint)[0]
}
output "rds_id" {
  value = aws_db_instance.postgres.id
}
