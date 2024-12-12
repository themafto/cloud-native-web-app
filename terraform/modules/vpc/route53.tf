
resource "aws_route53_record" "api" {
  zone_id = var.dns_zone_id
  name    = "api.${local.domain_name}"
  type    = local.type

  alias {
    evaluate_target_health = true
    name                   = local.alb_dns_name
    zone_id                = local.alb_zone_id
  }
}

resource "aws_route53_record" "cache" {
  name    = "cache.${local.domain_name}"
  type    = local.type
  zone_id = var.dns_zone_id

  alias {
    evaluate_target_health = true
    name                   = local.alb_dns_name
    zone_id                = local.alb_zone_id
  }
}