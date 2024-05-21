variable "subnet_ids" {
  description = "Subnets to launch the instances in."
  type        = list(string)
}

variable "server_image_id" {
  description = "The servers image id."
  type        = string
}

variable "s3_bucket" {
  description = "The bucket holding compute artefacts."
  type        = string
}

variable "s3_key" {
  description = "The key of the lambda function."
  type        = string
}

variable "endpoint_security_group" {
  description = "The vpc endpoint security group"
  type        = string
}

variable "vpc_id" {
  description = "The vpc id."
  type        = string
}

variable "sns_topic_arn" {
  description = "The arn of the sns topic that triggers the lambda."
  type        = string
}