resource "aws_cloudfront_origin_access_identity" "mypotal_website" {}

resource "aws_cloudfront_distribution" "mypotal_home_distribution" {
  depends_on = [
    aws_s3_bucket.mypotal_static,
    aws_cloudfront_origin_access_identity.mypotal_website
  ]
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "mypotal CloudFront Distribution"
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.mypotal_static.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.mypotal_static.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.mypotal_website.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.mypotal_static.id

    forwarded_values {
      query_string = true
      headers      = []
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }
  aliases = ["cloud-crab.com", "www.cloud-crab.com"]
}

resource "aws_cloudfront_distribution" "mypotal_app_distribution" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "mooon CloudFront Distribution"

  origin {
    domain_name = aws_instance.myinfla_ecs_instance.public_dns
    origin_id   = aws_instance.myinfla_ecs_instance.public_dns

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = aws_instance.myinfla_ecs_instance.public_dns

    forwarded_values {
      query_string = true  # クエリ文字列を転送
      headers      = ["*"] # すべてのヘッダーを転送

      cookies {
        forward = "all" # すべてのクッキーを転送
      }
    }

    viewer_protocol_policy = "redirect-to-https" # HTTPからHTTPSへリダイレクト
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = ["app.cloud-crab.com"]
}
