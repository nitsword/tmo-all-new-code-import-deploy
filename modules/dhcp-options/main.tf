##############################################
# DHCP Options (always created)
##############################################

resource "aws_vpc_dhcp_options" "this" {
  domain_name          = var.dhcp.domain_name
  domain_name_servers  = var.dhcp.domain_name_servers
  ntp_servers          = var.dhcp.ntp_servers
  netbios_name_servers = var.dhcp.netbios_name_servers
  netbios_node_type    = var.dhcp.netbios_node_type

  tags = {
    Name = "${var.name_prefix}-dhcp-options"
  }
}

##############################################
# DHCP Options Association (plan-safe)
##############################################

# Build static-key map for for_each
locals {
  dhcp_assoc_map = var.dhcp_enabled ? var.vpc_map : {}
}

resource "aws_vpc_dhcp_options_association" "assoc" {
  for_each = local.dhcp_assoc_map

  vpc_id          = each.value
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}
