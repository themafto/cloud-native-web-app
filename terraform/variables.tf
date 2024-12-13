
variable "region" {
  description = "AWS region name"
}
#RDS
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
variable "rds_image" {
  description = "RDS Database Image"
}
variable "dns_zone_id" {
  description = "Route53 zone id"
}
variable "acm_certificate_ssl" {
  description = "ACM certificate ssl"
}
variable "main_domain" {
}
variable "sub1_domain" {
}
variable "sub2_domain" {
}
variable "acm_certificate_ssl_us" {
  description = "ACM certificate ssl in US"
}
variable "dns_zone_id_cloudfront" {}

