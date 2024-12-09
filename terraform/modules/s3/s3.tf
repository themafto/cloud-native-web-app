resource "aws_s3_bucket" "front" {
  bucket = "frontend-${random_id.bucket_suffix.hex}" # Добавляем случайный суффикс }
  tags = {
    Name        = "frontend"
    Environment = "Dev"
    force_destroy = true # Осторожно в продакшене!
  }
}
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.front.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowVpcAccess",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:*",
        Resource = [
          aws_s3_bucket.front.arn,
          "${aws_s3_bucket.front.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = var.vpc_endpoint_id
          }
        }
      },
    ]
  })
}
