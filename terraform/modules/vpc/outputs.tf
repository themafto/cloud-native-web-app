output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3_endpoint.id
}
output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}
output "redis_security_group_id" {
  value = aws_security_group.redis_sg.id
}
output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}
output "private_subnet_a_id" {
  value = aws_subnet.private_subnet_a.id
}
output "private_subnet_b_id" {
  value = aws_subnet.private_subnet_b.id
}
output "aws_lb_target_group_rds_tg" {
  value = aws_lb_target_group.rds_tg.arn
}
output "aws_lb_target_group_redis_tg" {
  value = aws_lb_target_group.redis_tg.arn
}

