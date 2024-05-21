output "kms_key_arn" {
  description = "The arn of the kms key."
  value       = aws_kms_key.this.arn
}