resource "aws_ecr_repository" "rds" {
  name                 = "repo/rds"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository" "redis" {
  name                 = "repo/redis"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

