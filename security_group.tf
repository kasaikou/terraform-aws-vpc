locals {
  security_group_rules = { for name, config in var.security_groups : name => {
    type = config.type
    cidr_blocks = toset(concat(
      config.allow_global ? ["0.0.0.0/0"] : [],
      config.allow_local ? [var.cidr_block] : [],
      [for name in config.allow_local_subnets : var.subnets[name].cidr_block],
      config.allow_cidr_blocks,
    ))
    source_security_group_id = config.allow_local_security_group != null ? aws_security_group.security_groups[config.allow_local_security_group].id : null
    self                     = config.allow_self ? config.allow_self : null
    from_port                = length(config.port_range) > 0 ? min(config.port_range...) : 0
    to_port                  = length(config.port_range) > 0 ? max(config.port_range...) : 0
    protocol                 = config.protocol
  } }
}

resource "aws_security_group" "security_groups" {
  for_each = var.security_groups

  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = each.key
  }
}

resource "aws_security_group_rule" "security_groups" {
  for_each = local.security_group_rules

  security_group_id        = aws_security_group.security_groups[each.key].id
  type                     = each.value.type
  cidr_blocks              = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks : null
  source_security_group_id = each.value.source_security_group_id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
}
