import {
  id = var.R53_ZONE_ID          # リソースの識別子
  to = aws_route53_zone.mypotal # import対象
}

import {
  to = aws_route53_record.a_record
  id = RECORD_ID + SUBDOMAIN + DOMAIN + RECORD_TYPE
}

import {
  to = aws_route53_record.cname_record
  id = RECORD_ID + SUBDOMAIN + DOMAIN + RECORD_TYPE
}
