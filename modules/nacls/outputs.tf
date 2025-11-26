output "nacl_public" {
  description = "ID of public network ACL"
  value       = aws_network_acl.public.id
}

output "nacl_private" {
  description = "ID of private network ACL (applies to private + nonroutable subnets)"
  value       = aws_network_acl.private.id
}

output "associations" {
  description = "Map of NACL associations (subnet_key => assoc_id) for public and private"
  value = {
    public  = { for k, v in aws_network_acl_association.public_assoc : k => v.id }
    private = { for k, v in aws_network_acl_association.private_assoc : k => v.id }
  }
}
