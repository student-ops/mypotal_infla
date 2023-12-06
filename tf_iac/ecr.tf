resource "aws_ecr_repository" "ffit-1" {
  name                 = "ffit-1"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_iam_policy" "github_to_ecr_upload" {
  name        = "GithubToECRUploadPolicy"
  description = "Policy to allow uploading from Github to ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:*"
          #   "ecr:UploadLayerPart",
          #   "ecr:PutImage",
          #   "ecr:InitiateLayerUpload",
          #   "ecr:CompleteLayerUpload",
          #   "ecr:BatchCheckLayerAvailability"
        ],
        Resource = [
          "*",
        ]
      }
    ]
  })
}

resource "aws_iam_role" "github_ecr_uploader" {
  name = "GithubECRUploaderRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.openid_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : [
              "repo:student-ops/FFIT-1:*",
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_to_ecr_upload_attachment" {
  role       = aws_iam_role.github_ecr_uploader.name
  policy_arn = aws_iam_policy.github_to_ecr_upload.arn
}
