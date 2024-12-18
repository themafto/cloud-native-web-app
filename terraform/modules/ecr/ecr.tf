resource "aws_ecr_repository" "rds" {
  name                 = local.rds_name
  image_tag_mutability = local.rds_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "redis" {
  name                 = local.redis_name
  image_tag_mutability = local.redis_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }
}

