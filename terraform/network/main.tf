terraform {
  backend "s3" {}
}

resource "aws_vpc" "this" {

  cidr_block = local.vpc_cidr
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