#############################################
# Route Tables Outputs (Corrected for Per-AZ Maps)
#############################################

output "rt_public_id" {
  description = "Public route table ID (still a single resource)"
  # No change needed, as Public RT is still singular
  value       = aws_route_table.public.id
}

output "rt_private_ids" {
  description = "Map of Private Route Table IDs, keyed by AZ (a, b, c)."
  # Accesses the map of resources and extracts the ID from each one.
  value       = { for k, v in aws_route_table.private : k => v.id }
}

output "rt_nonroutable_ids" {
  description = "Map of Nonroutable Route Table IDs, keyed by AZ (a, b, c)."
  # Accesses the map of resources and extracts the ID from each one.
  value       = { for k, v in aws_route_table.nonroutable : k => v.id }
}

output "rt_private_tables" {
  description = "Map of Private Route Table objects, keyed by AZ (for referencing attributes)."
  # Exports the entire resource map if other modules need to reference ARN, tags, etc.
  value       = aws_route_table.private
}

output "rt_nonroutable_tables" {
  description = "Map of Nonroutable Route Table objects, keyed by AZ."
  value       = aws_route_table.nonroutable
}