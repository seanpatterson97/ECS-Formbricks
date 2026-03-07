########################################################################################################################
## Create Route53 Hosted Zone for the domain of the service including NS records in the top level domain.
## For this scenario, we assume that the service is running on a subdomain, like service.example.com.
########################################################################################################################

resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_record" "name_servers" {
  zone_id = var.tld_zone_id
  name    = var.domain_name
  type    = "NS"
  ttl     = 300
  records = [
    aws_route53_zone.main.name_servers[0],
    aws_route53_zone.main.name_servers[1],
    aws_route53_zone.main.name_servers[2],
    aws_route53_zone.main.name_servers[3]
  ]
}


########################################################################################################################
## Point A record to CloudFront distribution
########################################################################################################################

resource "aws_route53_record" "cloudfront_alias" {
  name    = var.domain_name
  type    = "A"
  zone_id = aws_route53_zone.main.id

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}
