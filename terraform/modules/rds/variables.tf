variable "db_password" {
  type = string
  description = "The password for the database"
  sensitive = true
}
variable "db_name" {
  type = string
  description = "The password for the database"
  sensitive = true
}
variable "db_username" {
  type = string
  description = "The password for the database"
  sensitive = true
}
variable "db_instance_class" {
  type = string
  description = "The instance class for the database"
}
variable "rds_security_group_id" {
  description = "rds_security_group_id"
}
variable "db_subnet_group_name" {
  description = "rds_subnet_group"
}