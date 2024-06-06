variable "create_endpoint" {
  description = "Set to yes if you want ssm vpc endpoints."
  type        = string
  default     = "no"
}

variable "internet_access" {
  description = "Set to yes if you want a internet access from the private subnet."
  type        = string
  default     = "no"
}