resource "aws_eip" "secure_ec2_eip" {
  domain   = "vpc"
  instance = aws_instance.secure_prog.id
}
