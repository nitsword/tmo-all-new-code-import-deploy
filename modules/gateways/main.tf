##############################################
# Gateways Module (AWS Provider v5 Compatible)
##############################################

##############################################
# INTERNET GATEWAY
##############################################

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = merge(
    { Name = "${var.name_prefix}-igw" },
    var.tags
  )
}

##############################################
# PUBLIC NAT GATEWAYS (Used by PRIVATE Subnets)
# --> Uses public subnets and Elastic IPs
##############################################

resource "aws_eip" "public_nat" {
  for_each = var.public_subnet_ids_map

  domain = "vpc"

  tags = merge(
    { Name = "${var.name_prefix}-eip-public-${each.key}" },
    var.tags
  )
}

resource "aws_nat_gateway" "public_nat" {
  for_each = var.public_subnet_ids_map

  allocation_id = aws_eip.public_nat[each.key].id
  subnet_id     = each.value

  tags = merge(
    { Name = "${var.name_prefix}-nat-public-${each.key}" },
    var.tags
  )
}

##############################################
# PRIVATE NAT GATEWAYS (Used by NON-ROUTABLE Subnets)
# --> NO EIP -- No Internet
##############################################

resource "aws_nat_gateway" "private_nat" {
  for_each = var.nonroutable_subnet_ids_map

  subnet_id = each.value

  # Key attribute enabling NAT *without* public access
  connectivity_type = "private"

  tags = merge(
    { Name = "${var.name_prefix}-nat-private-${each.key}" },
    var.tags
  )
}

##############################################
# OUTPUT HELPER LOCALS
##############################################

locals {
  public_nat_map  = { for k, gw in aws_nat_gateway.public_nat  : k => gw.id }
  private_nat_map = { for k, gw in aws_nat_gateway.private_nat : k => gw.id }
}
