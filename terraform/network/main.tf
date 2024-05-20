terraform {
  backend "s3" {}
}

resource "aws_vpc" "this" {

  cidr_block = local.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "fairground"
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = true
  availability_zone       = each.key
  cidr_block              = each.value

  tags = {
    "Name" = "fairground-pub-${split("-", each.key)[2]}"
  }
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    "Name" = "fairground-pri-${split("-", each.key)[2]}"
  }
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.this.id

  subnet_ids = [ for subnet in aws_subnet.private : subnet.id ]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = local.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = local.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

}

resource "aws_vpc_endpoint" "ssm" {
  count = var.create_endpoint == "yes" ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [ for subnet in aws_subnet.private : subnet.id ]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.end_point.id,
  ]
}

resource "aws_vpc_endpoint" "ssm_messages" {
  count = var.create_endpoint == "yes" ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-west-2.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [ for subnet in aws_subnet.private : subnet.id ]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.end_point.id,
  ]
}

resource "aws_vpc_endpoint" "ec2_messages" {
  count = var.create_endpoint == "yes" ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-west-2.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [ for subnet in aws_subnet.private : subnet.id ]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.end_point.id,
  ]
}

resource "aws_vpc_endpoint" "logs" {
  count = var.create_endpoint == "yes" ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-west-2.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [ for subnet in aws_subnet.private : subnet.id ]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.end_point.id,
  ]
}

resource "aws_vpc_endpoint" "ec2" {
  count = var.create_endpoint == "yes" ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.eu-west-2.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids = [ for subnet in aws_subnet.private : subnet.id ]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.end_point.id,
  ]
}

resource "aws_security_group" "end_point" {
  name = "endpoint"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = toset([ for key, value in local.private_subnets : value ])
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = toset([ for key, value in local.private_subnets : value ])
  }
}