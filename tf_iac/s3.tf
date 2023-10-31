resource "aws_s3_bucket" "my_potal_static" {
  bucket = "my-potal-static-content"

  tags = {
    Name        = "my-potal-bucket"
    Environment = "static"
  }
}
resource "aws_s3_bucket_website_configuration" "my_potal_website" {
  bucket = aws_s3_bucket.my_potal_static.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "src/"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "static_access_block" {
  bucket = aws_s3_bucket.my_potal_static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.my_potal_static.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:*",
        Resource = [
          "${aws_s3_bucket.my_potal_static.arn}/*",
          "${aws_s3_bucket.my_potal_static.arn}"
        ]
      }
    ]
  })
}
