resource "aws_route53_zone" "mypotal" {
  name = "${var.domain_name}."
}

resource "aws_route53_record" "mypotal_a" {
  zone_id = aws_route53_zone.mypotal.zone_id
  name    = "${var.domain_name}."
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.mypotal_home_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.mypotal_home_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_mypotal_a" {
  zone_id = aws_route53_zone.mypotal.zone_id
  name    = "www.${var.domain_name}."
  type    = "A"

  alias {
    name                   = "${var.domain_name}."
    zone_id                = aws_route53_zone.mypotal.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "app_mypotal_a" {
  zone_id = aws_route53_zone.mypotal.zone_id
  name    = "app.${var.domain_name}."
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.mypotal_app_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.mypotal_app_distribution.hosted_zone_id
    evaluate_target_health = false
  }

}
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.mypotal.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 300
}

# resource "aws_acm_certificate_validation" "cert_validation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
# }
