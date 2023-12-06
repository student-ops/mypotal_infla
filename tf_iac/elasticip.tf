resource "aws_eip" "secure_ec2_eip" {
  domain   = "vpc"
  instance = aws_instance.secure_prog.id
}

resource "aws_eip" "myinfla_ecs_eip" {
  domain   = "vpc"
  instance = aws_instance.myinfla_ecs_instance.id
}
