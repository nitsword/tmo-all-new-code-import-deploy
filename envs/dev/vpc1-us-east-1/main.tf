terraform {
  # This constraint allows any version 1.14.x, but not 1.15.0 or later.
  required_version = "~> 1.14.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # This constraint allows any version 5.x.x, but not 6.0.0 or later.
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

##############################################
# VPC
##############################################

module "vpc" {
  source     = "../../../modules/vpc"
  name       = var.name_prefix
  cidr_block = var.vpc.cidr
  tags       = var.vpc.tags
}

##############################################
# SUBNETS
##############################################

module "subnets" {
  source      = "../../../modules/subnets"
  vpc_id      = module.vpc.vpc_id
  name_prefix = var.name_prefix
  subnets     = var.subnets
  tags        = var.tags
}

##############################################
# GATEWAYS (NAT)
##############################################

module "gateways" {
  source = "../../../modules/gateways"

  vpc_id                        = module.vpc.vpc_id
  name_prefix                  = var.name_prefix
  tags                         = var.tags
  public_subnet_ids_map        = module.subnets.public_subnet_ids_map
  nonroutable_subnet_ids_map   = module.subnets.nonroutable_subnet_ids_map
}


##############################################
# ROUTE TABLES
##############################################

# module "rts" {
#   source = "../../../modules/route-tables"

#   vpc_id      = module.vpc.vpc_id
#   name_prefix = var.name_prefix

#   public_subnet_ids_map      = module.subnets.public_subnet_ids_map
#   private_subnet_ids_map     = module.subnets.private_subnet_ids_map
#   nonroutable_subnet_ids_map = module.subnets.nonroutable_subnet_ids_map

#   igw_id          = module.vpc.igw_id
#   nat_mode        = var.nat.type
#   nat_ids_map     = module.gateways.nat_ids_per_az
#   nat_single_id   = module.gateways.nat_id_single

#   route_tables = var.route_tables
# }

module "rts" {
  source = "../../../modules/route-tables"

  vpc_id      = module.vpc.vpc_id
  name_prefix = var.name_prefix

  public_subnet_ids_map      = module.subnets.public_subnet_ids_map
  private_subnet_ids_map     = module.subnets.private_subnet_ids_map
  nonroutable_subnet_ids_map = module.subnets.nonroutable_subnet_ids_map

  igw_id                = module.gateways.igw_id
  public_nat_ids_map    = module.gateways.public_nat_map
  private_nat_ids_map   = module.gateways.private_nat_map

  route_tables          = var.route_tables
  skip_existing_routes  = true
}


##############################################
# NACLs (public + private)
##############################################
# private NACL applies to private + nonroutable subnets
##############################################

locals {
  nacl_rules_for_module = {
    public  = var.nacl_rules.public
    private = var.nacl_rules.private
  }
}

module "nacls" {
  source = "../../../modules/nacls"

  vpc_id                     = module.vpc.vpc_id
  name_prefix                = var.name_prefix

  public_subnet_ids_map      = module.subnets.public_subnet_ids_map
  private_subnet_ids_map     = module.subnets.private_subnet_ids_map
  nonroutable_subnet_ids_map = module.subnets.nonroutable_subnet_ids_map

  nacl_rules = local.nacl_rules_for_module
}

##############################################
# DHCP OPTIONS
##############################################

module "dhcp" {
  source      = "../../../modules/dhcp-options"
  name_prefix = var.name_prefix

  dhcp_enabled = var.dhcp_enabled
  dhcp         = var.dhcp

  # vpc_map must be stable keys
  vpc_map = {
    v1 = module.vpc.vpc_id
  }
}

##############################################
# SECURITY GROUP
##############################################

module "security" {
  source = "../../../modules/security"

  vpc_id      = module.vpc.vpc_id
  name_prefix = var.name_prefix

  inbound  = var.sg_rules.inbound
  outbound = var.sg_rules.outbound

  tags = var.tags
}

##############################################
# VPC ENDPOINTS (FIXED)
##############################################

locals {
  interface_subnet_ids = values(module.subnets.private_subnet_ids_map)
  
  # FIX: Concatenate all Private and Nonroutable RT IDs from the new map outputs.
  gateway_route_table_ids = concat(
    values(module.rts.rt_private_ids),    # Retrieves all RT IDs for Private AZs (A, B, C)
    values(module.rts.rt_nonroutable_ids) # Retrieves all RT IDs for Nonroutable AZs (A, B, C)
  )
}

module "vpc_endpoints" {
  source = "../../../modules/vpc-endpoints"

  vpc_id                  = module.vpc.vpc_id
  name_prefix             = var.name_prefix
  interface_subnet_ids    = local.interface_subnet_ids
  gateway_route_table_ids = local.gateway_route_table_ids

  enabled = var.vpc_endpoints
}

##############################################
# OUTPUTS
##############################################

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.subnets.public_subnet_ids_map
}

output "private_subnets" {
  value = module.subnets.private_subnet_ids_map
}

output "nonroutable_subnets" {
  value = module.subnets.nonroutable_subnet_ids_map
}