### R53 Records ###
resource "aws_route53_record" "www" {
  zone_id = var.r53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.loadbalancer.dns_name
    zone_id                = aws_lb.loadbalancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "hello_cert_dns" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.ssl_certificate.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.ssl_certificate.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.ssl_certificate.domain_validation_options)[0].resource_record_type
  zone_id         = var.r53_zone_id
  ttl             = 60
}