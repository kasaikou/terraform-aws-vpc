resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "subnets" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = "${var.name}-${each.key}"
  }
}

locals {
  igws = toset(length([for name, config in var.route_tables : name if config.global_type == "igw"]) > 0 ? ["igw"] : [])
}

resource "aws_internet_gateway" "igws" {
  for_each = local.igws

  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "route_tables" {
  for_each = var.route_tables

  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}-${each.key}-rt"
  }
}

resource "aws_route" "global_igw" {
  for_each = { for k, v in var.route_tables : k => v if v.global_type == "igw" }

  route_table_id         = aws_route_table.route_tables[each.key].id
  gateway_id             = aws_internet_gateway.igws["igw"].id
  destination_cidr_block = "0.0.0.0/0"
}

locals {
  subnet_route_table_associations = merge([for subnet_name, subnet_config in var.subnets : { for route_table in subnet_config.route_tables :
    "${subnet_name}@${route_table}" => {
      route_table_id = aws_route_table.route_tables[route_table].id
      subnet_id      = aws_subnet.subnets[subnet_name].id
    }
  }]...)
}

resource "aws_route_table_association" "route_table_associations" {
  for_each = local.subnet_route_table_associations

  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}
