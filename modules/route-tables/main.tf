##############################################
# Route Tables Module (Provider v5 Compatible)
##############################################

###############################
# DISCOVER VPC CIDR BLOCK
###############################
data "aws_vpc" "current" {
  id = var.vpc_id
}

##########################################
# Public Route Table (Single RT)
##########################################

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.name_prefix}-rt-public"
  }
}

locals {
  public_existing_cidrs = toset([])

  public_routes = {
    for r in try(var.route_tables.public.routes, []) :
    "${r.cidr}-${r.target}" => r
  }

  public_routes_to_create = var.skip_existing_routes ? {
    for k, r in local.public_routes : k => r
    if !contains(local.public_existing_cidrs, r.cidr)
  } : local.public_routes
}

resource "aws_route" "public_routes" {
  for_each               = local.public_routes_to_create
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = each.value.cidr
  gateway_id             = each.value.target == "igw" ? var.igw_id : null
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = var.public_subnet_ids_map
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

##########################################
# Private Route Table (Per-AZ Logic)
##########################################

resource "aws_route_table" "private" {
  for_each = var.private_subnet_ids_map
  vpc_id   = var.vpc_id
  tags = {
    Name = "${var.name_prefix}-rt-private-${each.key}"
  }
}

locals {
  private_existing_cidrs = toset([])

  private_routes_by_az = {
    for r in try(var.route_tables.private.routes, []) :
    r.az_key => r
    if r.target == "nat" && r.az_key != null
  }

  private_routes_to_create = {
    for k, r in local.private_routes_by_az : k => r
    if !contains(local.private_existing_cidrs, r.cidr)
  }
}

resource "aws_route" "private_routes" {
  for_each               = local.private_routes_to_create
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = each.value.cidr

  # FIX 💡 Uses PUBLIC NAT for private subnets
  nat_gateway_id = lookup(var.public_nat_ids_map, each.key, null)
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = var.private_subnet_ids_map
  subnet_id      = each.value
  route_table_id = aws_route_table.private[each.key].id
}

##########################################
# Non-Routable Route Table (Per-AZ Logic)
##########################################

resource "aws_route_table" "nonroutable" {
  for_each = var.nonroutable_subnet_ids_map
  vpc_id   = var.vpc_id
  tags = {
    Name = "${var.name_prefix}-rt-nonroutable-${each.key}"
  }
}

locals {
  nonroutable_existing_cidrs = toset([])

  nonroutable_routes_by_az = {
    for r in try(var.route_tables.nonroutable.routes, []) :
    r.az_key => r
    if r.target == "nat" && r.az_key != null
  }

  nonroutable_routes_to_create = {
    for k, r in local.nonroutable_routes_by_az : k => r
    if !contains(local.nonroutable_existing_cidrs, r.cidr)
  }
}

resource "aws_route" "nonroutable_routes" {
  for_each               = local.nonroutable_routes_to_create
  route_table_id         = aws_route_table.nonroutable[each.key].id
  destination_cidr_block = each.value.cidr

  # FIX 💡 Uses PRIVATE NAT for non-routable subnets
  nat_gateway_id = lookup(var.private_nat_ids_map, each.key, null)
}

resource "aws_route_table_association" "nonroutable_assoc" {
  for_each       = var.nonroutable_subnet_ids_map
  subnet_id      = each.value
  route_table_id = aws_route_table.nonroutable[each.key].id
}
