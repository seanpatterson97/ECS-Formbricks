########################################################################################################################
## CloudFront VPC Origin — allows CloudFront to reach the internal ALB via private networking
########################################################################################################################

resource "aws_cloudfront_vpc_origin" "alb" {
  vpc_origin_endpoint_config {
    name                   = "${var.project}-vpc-origin-${var.environment}"
    arn                    = aws_lb.alb.arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "http-only"
    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }
}

########################################################################################################################
## CloudFront Distribution
########################################################################################################################

resource "aws_cloudfront_distribution" "main" {
  comment         = "${var.project} CloudFront Distribution"
  enabled         = true
  is_ipv6_enabled = true
  aliases         = ["${var.domain_name}"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_lb.alb.name
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id          = aws_cloudfront_cache_policy.formbricks_policy.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = aws_lb.alb.name

    vpc_origin_config {
      vpc_origin_id            = aws_cloudfront_vpc_origin.alb.id
      origin_keepalive_timeout = 60
      origin_read_timeout      = 60
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront_certificate.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = {
    Name = "${var.project}_CloudFront_${var.environment}"
  }
}

resource "aws_cloudfront_cache_policy" "formbricks_policy" {
  name        = "${var.project}-cache-policy"
  comment     = "Cache policy for Formbricks Next.js app"
  default_ttl = 0
  max_ttl     = 86400
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "Authorization",
          "CloudFront-Viewer-Country",
          "Host",
          "Accept",
          "Accept-Language"
        ]
      }
    }

    query_strings_config {
      query_string_behavior = "all"
    }

    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
  }
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}
