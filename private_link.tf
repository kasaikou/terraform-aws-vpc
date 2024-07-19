resource "aws_vpc_endpoint" "interfaces" {
  for_each = var.vpc_interface_endpoints

  vpc_id              = aws_vpc.vpc.id
  subnet_ids          = toset([for name, config in var.subnets : aws_subnet.subnets[name].id if contains(config.vpc_interface_endpoints, each.key)])
  security_group_ids  = each.value.security_groups != null ? toset([for name in each.value.security_groups : aws_security_group.security_groups[name].id]) : null
  vpc_endpoint_type   = "Interface"
  service_name        = each.key
  private_dns_enabled = each.value.private_dns_enabled

  tags = {
    Name = "${var.name}-interface-${each.key}"
  }
}

resource "aws_vpc_endpoint" "gateways" {
  for_each = var.vpc_gateway_endpoints

  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = each.key

  tags = {
    Name = "${var.name}-gateway-${each.key}"
  }
}

locals {
  vpce_rt_associations = merge([for rt_name, rt_config in var.route_tables : {
    for vpce_name in rt_config.vpc_gateway_endpoints :
    "${vpce_name}@${rt_name}" => {
      vpc_endpoint_id = aws_vpc_endpoint.gateways[vpce_name].id
      route_table_id  = aws_route_table.route_tables[rt_name].id
    }
    if contains(keys(var.vpc_gateway_endpoints), vpce_name)
  }]...)
}

resource "aws_vpc_endpoint_route_table_association" "vpce_rt_associations" {
  for_each = local.vpce_rt_associations

  vpc_endpoint_id = each.value.vpc_endpoint_id
  route_table_id  = each.value.route_table_id
}
