resource "aws_key_pair" "ecs_ecs_key" {
  key_name   = "ec2_ecs_key"
  public_key = file(var.public_key_path) # 変数を使用してパスを指定
}


resource "aws_instance" "myinfla_ecs_instance" {
  ami                         = "ami-0fda573abc329ed59"
  instance_type               = var.awsprops["prod_itype"]
  subnet_id                   = aws_subnet.my_subnet.id
  associate_public_ip_address = var.awsprops["publicip"]
  key_name                    = aws_key_pair.ecs_ecs_key.key_name

  vpc_security_group_ids = [
    aws_security_group.mypotal_vpc_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name        = var.instancename
    Environment = "ECS"
    OS          = "AMAZON LINUX 2"
    Managed     = "TF"
  }

  # depends_on = [aws_security_group.moon_vpc_sg]
  user_data = local.ecs_agent
}

locals {
  ecs_agent = templatefile("${path.module}/updated_userdata.sh", {
    ecs_cluster_name = aws_ecs_cluster.myinfla_cluster.name,
  })
  ecs_instance_userdata = templatefile("${path.module}/userdata.sh", {
    ecs_cluster_name = aws_ecs_cluster.myinfla_cluster.name,
  })
}


output "myinfla_ecs_ssh_command" {
  value = "ssh -i ${var.public_key_path} ec2-user@${aws_eip.myinfla_ecs_eip.public_ip}"
}
