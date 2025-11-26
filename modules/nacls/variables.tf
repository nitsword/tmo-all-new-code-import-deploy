variable "vpc_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "public_subnet_ids_map" {
  type        = map(string)
  description = "Map of public subnet ids keyed by stable key (e.g. a,b,c)"
}

variable "private_subnet_ids_map" {
  type        = map(string)
  description = "Map of private subnet ids keyed by stable key"
}

variable "nonroutable_subnet_ids_map" {
  type        = map(string)
  description = "Map of nonroutable subnet ids keyed by stable key"
}

variable "nacl_rules" {
  description = <<-EOT
Map of lists of NACL rules. Keys: "public" and "private".
Each rule object must include:
  - rule_no (number)
  - protocol (string, e.g. "6" for TCP, "17" for UDP, "-1" for all)
  - from (number)  -> from_port
  - to (number)    -> to_port
  - cidr (string)  -> cidr_block
  - egress (bool)  -> true = egress rule, false = ingress rule

Example:
nacl_rules = {
  public = [
    { rule_no=100, protocol="6", from=443, to=443, cidr="0.0.0.0/0", egress=false }
  ]
  private = [
    { rule_no=100, protocol="6", from=443, to=443, cidr="10.0.0.0/8", egress=false }
  ]
}
EOT

  type = map(list(object({
    rule_no  = number
    protocol = string
    from     = number
    to       = number
    cidr     = string
    egress   = bool
  })))

  default = {}
}
