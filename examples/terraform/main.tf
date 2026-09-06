# Minimal, commented CloudFront + S3 + Origin Access Control + WAF skeleton.
#
# This is a reading/learning example, not a one-command production deployment.
# Review every resource before applying, and always run `terraform plan` first.
# Apply is manual and deliberate — this repository's CI never runs `terraform apply`.
#
# Cost and cleanup: see ../../docs/COST_AND_CLEANUP.md

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.63"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # Mumbai origin region, matching the architecture diagram
}

# WAF Web ACLs for CloudFront must be created in us-east-1, regardless of origin region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for the static origin"
  type        = string
}

# --- Origin: private S3 bucket, no public access ---

resource "aws_s3_bucket" "origin" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "origin" {
  bucket                  = aws_s3_bucket.origin.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Origin Access Control: only CloudFront may read from the bucket ---

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "origin" {
  bucket = aws_s3_bucket.origin.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudFrontServicePrincipalReadOnly"
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.origin.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
        }
      }
    }]
  })
}

# --- WAF: baseline managed rules + a rate-based rule ---

resource "aws_wafv2_web_acl" "this" {
  provider    = aws.us_east_1
  name        = "${var.bucket_name}-web-acl"
  scope       = "CLOUDFRONT"
  description = "Baseline managed rules plus a rate-based rule, scoped to the CloudFront distribution"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      count {} # Start in count mode — review sampled requests before switching to block. See labs/02.
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimitPerIP"
    priority = 2
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 2000 # requests per 5-minute window; tune against real traffic first
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitPerIP"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.bucket_name}-web-acl"
    sampled_requests_enabled   = true
  }
}

# --- CloudFront distribution ---

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # cheapest tier for a learning lab — see docs/COST_AND_CLEANUP.md
  web_acl_id          = aws_wafv2_web_acl.this.arn

  origin {
    domain_name              = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600  # 1 hour default — shorten for anything that changes per deploy
    max_ttl     = 86400 # 24 hours max
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # replace with an ACM certificate + custom domain for real use
  }
}

output "distribution_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}
