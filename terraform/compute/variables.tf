variable "subnet_ids" {
  description = "Subnets to launch the instances in."
  type = list(string)
}

variable "server_image_id" {
  description = "The servers image id."
  type = string
}