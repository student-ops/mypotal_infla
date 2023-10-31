resource "aws_s3_bucket" "my_potal_static" {
  bucket = "my-potal-static-content"

  tags = {
    Name        = "my-potal-bucket"
    Environment = "static"
  }
}
