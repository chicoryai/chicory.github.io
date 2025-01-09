resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.app_name}-bucket"
  tags = {
    Name = "${var.app_name}-bucket"
  }
}
