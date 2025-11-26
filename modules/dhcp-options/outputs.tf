##############################################
# DHCP Options Module - Outputs
##############################################

output "dhcp_options_id" {
  description = "ID of the DHCP options set"
  value       = aws_vpc_dhcp_options.this.id
}

output "dhcp_associations" {
  description = "Map of DHCP associations (keyed by vpc_map key)"
  value = {
    for k, v in aws_vpc_dhcp_options_association.assoc :
    k => {
      vpc_id          = v.vpc_id
      dhcp_options_id = v.dhcp_options_id
    }
  }
}
