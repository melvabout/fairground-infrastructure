output "private_subnets_list" {
  description = "List of private subnets."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnets_list" {
  description = "List of public subnets."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "end_point_aws_security_group_id" {
  description = "The id of the vpc endpoint security group."
  value       = aws_security_group.end_point.id
}

output "this_aws_vpc_id" {
  description = "The vpc id."
  value       = aws_vpc.this.id
}