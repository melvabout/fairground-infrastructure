output "private_subnets_list" {
  description = "List of private subnets."
  value = [ for subnet in aws_subnet.private : subnet.id ]
}

output "public_subnets_list" {
  description = "List of public subnets."
  value = [ for subnet in aws_subnet.public : subnet.id ]
}