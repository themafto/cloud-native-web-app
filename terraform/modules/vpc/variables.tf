variable "region" {}
variable "dns_zone_id" {
  description = "Route53 zone id"
}
variable "acm_certificate_ssl" {
  description = "Route53 SSL certificate"
}
variable "cloudfront_domain_name" {
  description = "Domain name (i.e. website-domain)."
}
variable "dns_zone_id_cloudfront" {}