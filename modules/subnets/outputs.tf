output "public_subnet_ids_map" {
  value = { for k, s in aws_subnet.public : k => s.id }
}

output "private_subnet_ids_map" {
  value = { for k, s in aws_subnet.private : k => s.id }
}

output "nonroutable_subnet_ids_map" {
  value = { for k, s in aws_subnet.nonroutable : k => s.id }
}
