terraform {
  backend "s3" {}
}

resource "aws_s3_bucket" "compute" {
  bucket = "${data.aws_caller_identity.current.account_id}-compute-artifacts"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "compute" {
  bucket = aws_s3_bucket.compute.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}