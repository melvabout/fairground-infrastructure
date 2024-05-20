terraform {
  backend "s3" {}
}

resource "aws_kms_key" "this" {
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "this" {
  target_key_id = aws_kms_key.this.id
  name = "alias/fairgound-kms-key-alias" 
}