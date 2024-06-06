terraform {
  backend "s3" {}
}

resource "aws_vpc" "this" {

  cidr_block           = local.vpc_cidr
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

  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = local.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 49152
    to_port    = 65535
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = local.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 2375
    to_port    = 2375
  }

  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

}

resource "aws_vpc_endpoint" "ssm" {
  count = var.create_endpoint == "yes" ? 1 : 0

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.end_point.id,
  ]
}

resource "aws_vpc_endpoint" "ssm_messages" {
  count = var.create_endpoint == "yes" ? 1 : 0

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.eu-west-2.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.end_point.id,
  ]
}

resource "aws_vpc_endpoint" "ec2_messages" {
  count = var.create_endpoint == "yes" ? 1 : 0

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.eu-west-2.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.end_point.id,
  ]
}

resource "aws_vpc_endpoint" "logs" {
  count = var.create_endpoint == "yes" ? 1 : 0

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.eu-west-2.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.end_point.id,
  ]
}

resource "aws_vpc_endpoint" "ec2" {
  count = var.create_endpoint == "yes" ? 1 : 0

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.eu-west-2.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private : subnet.id]
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.end_point.id,
  ]
}

resource "aws_security_group" "end_point" {
  name   = "endpoint"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = toset([for key, value in local.private_subnets : value])
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = toset([for key, value in local.private_subnets : value])
  }
}

resource "aws_internet_gateway" "this" {
  count = var.internet_access == "yes" ? 1 : 0
  vpc_id = aws_vpc.this.id
}

resource "aws_eip" "nat_gateway" {
  count = var.internet_access == "yes" ? 1 : 0
  depends_on                = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = var.internet_access == "yes" ? 1 : 0
  subnet_id = aws_subnet.public["eu-west-2a"].id
  allocation_id = aws_eip.nat_gateway[0].id
}

resource "aws_route_table" "private" {
  count = var.internet_access == "yes" ? 1 : 0
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "nat_ngw_route" {
  count = var.internet_access == "yes" ? 1 : 0
  
  route_table_id         = aws_route_table.private[0].id
  nat_gateway_id         = aws_nat_gateway.this[0].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private" {
  for_each = var.internet_access == "yes" ? local.private_subnets : {}

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_flow_log" "this" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.this.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
}

resource "aws_cloudwatch_log_group" "this" {
  name = "vpc"
}

resource "aws_iam_role" "flow_log" {
  name               = "flow_log"
  assume_role_policy = data.aws_iam_policy_document.flow_log_assume.json
}

resource "aws_iam_role_policy" "flow_log" {
  name   = "flow_log"
  role   = aws_iam_role.flow_log.id
  policy = data.aws_iam_policy_document.flow_log.json
}
