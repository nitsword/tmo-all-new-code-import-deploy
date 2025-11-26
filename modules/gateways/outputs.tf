output "igw_id" {
  value       = aws_internet_gateway.igw.id
  description = "Internet Gateway ID"
}

output "public_nat_map" {
  value       = local.public_nat_map
  description = "Map of AZ → Public NAT Gateway IDs"
}

output "private_nat_map" {
  value       = local.private_nat_map
  description = "Map of AZ → Private NAT Gateway IDs"
}
