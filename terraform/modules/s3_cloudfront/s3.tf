resource "aws_s3_bucket" "site_origin" {
  bucket          = "site-origin-${random_id.bucket_suffix.hex}"
  tags            = {
    Environment   = "Dev"
    force_destroy = false # Be careful with production!(if true)
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
  bucket   = aws_s3_bucket.site_origin.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_cloudfront_origin_access_control" "site_access" {
  name                              = "security_pillar100_cf_s3_oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site_access" {

  aliases = local.aliases

  enabled         = true
  default_root_object = local.default_root_object

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_s3_bucket.site_origin.id
    viewer_protocol_policy = "https-only"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name              = aws_s3_bucket.site_origin.bucket_domain_name
    origin_id                = aws_s3_bucket.site_origin.id
    origin_access_control_id = aws_cloudfront_origin_access_control.site_access.id
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_ssl_us
    ssl_support_method       = local.ssl_support_method
    minimum_protocol_version = local.minimum_protocol_version
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
    sid     = "s3_cloudfront_static_website"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
    ]

    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    resources     = ["arn:aws:s3:::${aws_s3_bucket.site_origin.bucket}/*"]
    condition {
      test        = "StringEquals"
      values      = [aws_cloudfront_distribution.site_access.arn]
      variable    = "AWS:SourceARN"
    }


  }
}

