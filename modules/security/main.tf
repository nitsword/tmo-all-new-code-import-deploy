##############################################
# SECURITY GROUP MODULE (dynamic rules)
##############################################

resource "aws_security_group" "default" {
  name        = "${var.name_prefix}-sg"
  description = "Security group managed by Terraform module"
  vpc_id      = var.vpc_id

  tags = merge(
    { Name = "${var.name_prefix}-sg" },
    var.tags
  )
}

##############################################
# INBOUND RULES (dynamic)
##############################################

resource "aws_security_group_rule" "inbound" {
  for_each = {
    for r in var.inbound :
    "${r.description}-${r.cidr}-${r.from}-${r.to}" => r
  }

  type              = "ingress"
  security_group_id = aws_security_group.default.id

  protocol         = each.value.protocol
  from_port        = each.value.from
  to_port          = each.value.to
  cidr_blocks      = [each.value.cidr]
  description      = each.value.description
}

##############################################
# OUTBOUND RULES (dynamic)
##############################################

resource "aws_security_group_rule" "outbound" {
  for_each = {
    for r in var.outbound :
    "${r.description}-${r.cidr}-${r.from}-${r.to}" => r
  }

  type              = "egress"
  security_group_id = aws_security_group.default.id

  protocol         = each.value.protocol
  from_port        = each.value.from
  to_port          = each.value.to
  cidr_blocks      = [each.value.cidr]
  description      = each.value.description
}
