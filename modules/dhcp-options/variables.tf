##############################################
# DHCP Options Module - Variables
##############################################

variable "name_prefix" {
  type        = string
  description = "Prefix for naming DHCP resources"
}

variable "dhcp_enabled" {
  type        = bool
  description = "Whether DHCP options association should be enabled"
  default     = false
}

variable "dhcp" {
  description = "DHCP options configuration"
  type = object({
    domain_name          = string
    domain_name_servers  = list(string)
    ntp_servers          = list(string)
    netbios_name_servers = list(string)
    netbios_node_type    = number
  })
}

# IMPORTANT:
# must be a MAP with STATIC KEYS for plan-safe for_each
#
# Example:
# vpc_map = {
#   v1 = "vpc-123abc"
# }
#
variable "vpc_map" {
  type        = map(string)
  description = "Map of VPC IDs for DHCP association (keys must be static)"
  default     = {}
}
