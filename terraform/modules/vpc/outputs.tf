output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3_endpoint.id
}
output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}
output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}