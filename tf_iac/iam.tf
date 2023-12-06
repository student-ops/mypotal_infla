resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment_ecs_efs" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.efs_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment_ecs_ecr" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.access_ecs_ecr_policy.arn
}

resource "aws_iam_role" "ec2_role" {
  name = "ECSEFSRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
      },
    ]
  })
}
resource "aws_iam_policy" "access_ecs_ecr_policy" {
  name        = "ECSRolePolicy"
  description = "Policy to allow EC2 instances to interact with ECS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecs:RegisterContainerInstance",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Submit*",
          "ecs:Poll",
          "ecr:*",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}



resource "aws_iam_policy" "efs_access_policy" {
  name        = "EFSAccessPolicy"
  description = "Policy to allow EC2 instances to access EFS"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite",
                "elasticfilesystem:ClientRootAccess"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}
