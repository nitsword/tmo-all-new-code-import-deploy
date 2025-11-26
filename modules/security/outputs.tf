output "security_group_id" {
  value       = aws_security_group.default.id
  description = "ID of the security group"
}
