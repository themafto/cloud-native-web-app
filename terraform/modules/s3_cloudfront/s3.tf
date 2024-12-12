resource "aws_s3_bucket" "site_origin" {
  bucket          = "site-origin-${random_id.bucket_suffix.hex}"# Добавляем случайный суффикс }
  tags            = {
    Environment   = "Dev"
    force_destroy = false # Осторожно в продакшене!(if true)
  }
}
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_account_public_access_block" "site_origin" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_server_side_encryption_configuration" "site_origin" {
  bucket = aws_s3_bucket.site_origin.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_versioning" "site_origin" {
  bucket = aws_s3_bucket.site_origin.bucket
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_object" "content" {
  depends_on = [aws_s3_bucket.site_origin]
  bucket = aws_s3_bucket.site_origin.bucket
  key    = "index.html"
  source = "frontend/templates/index.html"
  server_side_encryption = "AES256"
  content_type = "text/html"
}
resource "aws_cloudfront_origin_access_control" "site_access" {
  name = "security_pillar100_cf_s3_oac"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}
resource "aws_cloudfront_distribution" "site_access" {

  depends_on = [
  aws_s3_bucket.site_origin,
  aws_cloudfront_origin_access_control.site_access
  ]

  aliases = ["themafto.com"]

  enabled         = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.site_origin.id
    viewer_protocol_policy = "https-only"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.site_origin.bucket_domain_name
    origin_id   = aws_s3_bucket.site_origin.id
    origin_access_control_id = aws_s3_bucket.site_origin.id
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_s3_bucket_policy" "site_origin" {
  depends_on = [data.aws_iam_policy_document.site_origin]
  bucket     = aws_s3_bucket.site_origin.id
  policy     = data.aws_iam_policy_document.site_origin.json
}

data "aws_iam_policy_document" "site_origin" {
  depends_on = [
    aws_cloudfront_origin_access_control.site_access,
    aws_s3_bucket.site_origin
  ]

  statement {
    sid    = "s3_cloudfront_static_website"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]

    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type = "Service"
    }
    resources = ["arn:aws:s3:::${aws_s3_bucket.site_origin.bucket}/*"]
    condition {
      test     = "StringEquals"
      values = [aws_cloudfront_distribution.site_access.arn]
      variable = "AWS:SourceARN"
    }


  }
}

