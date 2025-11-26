##################################
# NACLs module (provider v5) - PLAN-SAFE
#
# Two NACLs:
#  - aws_network_acl.public   -> associated to public subnets
#  - aws_network_acl.private  -> associated to private + nonroutable subnets
##################################

# PUBLIC NACL
resource "aws_network_acl" "public" {
  vpc_id = var.vpc_id
  tags   = { Name = "${var.name_prefix}-nacl-public" }

  # ingress rules (egress == false)
  dynamic "ingress" {
    for_each = [
      for r in try(var.nacl_rules.public, []) : r
      if lookup(r, "egress", false) == false
    ]
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = "allow"
      cidr_block = ingress.value.cidr
      from_port  = ingress.value.from
      to_port    = ingress.value.to
    }
  }

  # egress rules (egress == true)
  dynamic "egress" {
    for_each = [
      for r in try(var.nacl_rules.public, []) : r
      if lookup(r, "egress", false) == true
    ]
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = "allow"
      cidr_block = egress.value.cidr
      from_port  = egress.value.from
      to_port    = egress.value.to
    }
  }
}

# Associate public NACL to public subnets
resource "aws_network_acl_association" "public_assoc" {
  for_each       = var.public_subnet_ids_map
  subnet_id      = each.value
  network_acl_id = aws_network_acl.public.id
}

# PRIVATE NACL (used for both private + nonroutable subnets)
resource "aws_network_acl" "private" {
  vpc_id = var.vpc_id
  tags   = { Name = "${var.name_prefix}-nacl-private" }

  dynamic "ingress" {
    for_each = [
      for r in try(var.nacl_rules.private, []) : r
      if lookup(r, "egress", false) == false
    ]
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = "allow"
      cidr_block = ingress.value.cidr
      from_port  = ingress.value.from
      to_port    = ingress.value.to
    }
  }

  dynamic "egress" {
    for_each = [
      for r in try(var.nacl_rules.private, []) : r
      if lookup(r, "egress", false) == true
    ]
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = "allow"
      cidr_block = egress.value.cidr
      from_port  = egress.value.from
      to_port    = egress.value.to
    }
  }
}

# Merge private + nonroutable to associate same private NACL to both sets of subnets
locals {
  private_and_nonroutable = merge(var.private_subnet_ids_map, var.nonroutable_subnet_ids_map)
}

resource "aws_network_acl_association" "private_assoc" {
  for_each       = local.private_and_nonroutable
  subnet_id      = each.value
  network_acl_id = aws_network_acl.private.id
}
