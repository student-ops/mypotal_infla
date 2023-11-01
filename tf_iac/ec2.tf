variable "awsprops" {
  type = map(string)
  default = {
    region = "ap-northeast-1"
    # ami        = "ami-04beabd6a4fb6ab6f" # AMAZON LINUX 2
    # ami          = "ami-0fda573abc329ed59" # ECS optimized AMAZON LINUX 2023
    ami          = "ami-09a81b370b76de6a2" # UBUNTU 22.04
    prod_itype   = "t2.micro"
    publicip     = true
    keyname      = "myseckey"
    secgroupname = "mypotal_vpc_sg"
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = var.awsprops["keyname"]
  public_key = file(var.public_key_path) # 変数を使用してパスを指定
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.efs_access_policy.arn
}

resource "aws_instance" "secure_prog" {
  ami                         = var.awsprops["ami"]
  instance_type               = var.awsprops["prod_itype"]
  subnet_id                   = aws_subnet.my_subnet.id
  associate_public_ip_address = var.awsprops["publicip"]
  key_name                    = aws_key_pair.my_key.key_name

  vpc_security_group_ids = [
    aws_security_group.mypotal_vpc_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  tags = {
    Name        = var.instancename
    Environment = "DEV"
    OS          = "UBUNTU"
    Managed     = "IAC"
  }

  depends_on = [aws_security_group.mypotal_vpc_sg]
}

output "prod_ssh_command" {
  value = "ssh -i ~/.ssh/myPotal ec2-user@${aws_eip.secure_ec2_eip.public_ip}" # Elastic IPを使用
}
