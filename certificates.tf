########################################################################################################################
## Certificate for CloudFront Distribution
## CloudFront requires certificates to be in us-east-1, so these resources use the aliased provider.
########################################################################################################################

resource "aws_acm_certificate" "cloudfront_certificate" {
  provider                  = aws.us_east_1
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.domain_name}"]

}

resource "aws_acm_certificate_validation" "cloudfront_certificate" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cloudfront_certificate.arn
  validation_record_fqdns = [aws_route53_record.generic_certificate_validation.fqdn]
}

########################################################################################################################
## DNS validation record for the CloudFront certificate
########################################################################################################################

resource "aws_route53_record" "generic_certificate_validation" {
  name    = tolist(aws_acm_certificate.cloudfront_certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cloudfront_certificate.domain_validation_options)[0].resource_record_type
  zone_id = aws_route53_zone.main.id
  records = [tolist(aws_acm_certificate.cloudfront_certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 300
}
