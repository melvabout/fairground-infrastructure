output "bucket_id" {
  description = "The S3 bucket."
  value = aws_s3_bucket.compute.id
}