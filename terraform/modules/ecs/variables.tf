variable "rds_endpoint" {
  description = "RDS Endpoint"
}

variable "db_username" {
  description = "RDS Database Username"
}
variable "db_password" {

}
variable "db_name" {
  description = "The name of the database"
}
variable "rds_repository" {
  description = "Ecr repository"
}

#vpc
variable "private_subnet_a_id" {
  description = "rds private subnet id"
}
variable "private_subnet_b_id" {
  description = "rds private subnet id"
}
variable "aws_lb_target_group_rds_tg_arn" {
  description = "lb_target_group_rds"
}
variable "aws_lb_target_group_redis_tg_arn" {
  description = "lb_target_group_redis_tg_arn"
}
variable "rds_security_group_id" {
  description = "id of the security group for the RDS fargate service"
}
variable "rds_id" {
  description = "db id of the RDS instance"
}
variable "main_domain" {
}
variable "sub1_domain" {
}
variable "sub2_domain" {
}
variable "redis_image" {
  description = "Redis Docker Image"
}
variable "redis_security_group_id" {
  description = "Redis Security Group for Redis"
}
variable "redis_endpoint_host" {
  description = "Redis host to connect Redis"
}


