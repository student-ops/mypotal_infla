resource "aws_s3_bucket" "mypotal_static" {
  bucket = "my-potal-static-content"

  tags = {
    Name        = "my-potal-bucket"
    Environment = "static"
  }
}
resource "aws_s3_bucket_website_configuration" "my_potal_website" {
  bucket = aws_s3_bucket.mypotal_static.id

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
  bucket = aws_s3_bucket.mypotal_static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.mypotal_static.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:*",
        Resource = [
          "${aws_s3_bucket.mypotal_static.arn}/*",
          "${aws_s3_bucket.mypotal_static.arn}"
        ]
      }
    ]
  })
}
resource "aws_iam_policy" "github_to_s3_upload" {
  name        = "GithubToS3UploadPolicy"
  description = "Policy to allow uploading from Github to S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "${aws_s3_bucket.mypotal_static.arn}/*",
          "${aws_s3_bucket.mypotal_static.arn}" // Bucket itself also should be added for actions like ListBucket
        ]
      }
    ]
  })
}


resource "aws_iam_role" "github_s3_uploader" {
  name = "GithubS3UploaderRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.openid_provider_arn # oidc provider arn 
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : [
              "repo:student-ops/mypotal_next_bootstrap:*",
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_s3_uploader_attach" {
  policy_arn = aws_iam_policy.github_to_s3_upload.arn
  role       = aws_iam_role.github_s3_uploader.name
}
