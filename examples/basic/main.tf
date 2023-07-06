provider "aws" {
  region = "eu-west-1"
}

module "this" {
  source = "../.."

  name        = "cloudfront-logs"
  bucket_name = "cloudfront-logs"

  retention = 30
}

data "aws_cloudfront_cache_policy" "managed-caching-optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "this" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket_website_configuration.this.website_endpoint
    origin_id   = aws_s3_bucket_website_configuration.this.bucket

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"

      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  default_cache_behavior {
    compress               = true
    target_origin_id       = aws_s3_bucket_website_configuration.this.bucket # need to match self.origin.origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]

    cache_policy_id = data.aws_cloudfront_cache_policy.managed-caching-optimized.id
  }

  logging_config {
    bucket = module.this.this_s3_bucket.bucket_domain_name
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket = "static"
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
}
