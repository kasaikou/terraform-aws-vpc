output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  value = { for name, subnet in aws_subnet.subnets : name => subnet.id }
}

output "security_group_ids" {
  value = { for name, security_group in aws_security_group.security_groups : name => security_group.id }
}

output "route_table_ids" {
  value = { for name, route_table in aws_route_table.route_tables : name => route_table.id }
}
