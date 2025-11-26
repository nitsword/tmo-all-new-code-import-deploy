#############################################
# Route Tables Module Variables
#############################################

variable "vpc_id" {
  type        = string
  description = "VPC ID where route tables will be created"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming route tables"
}

#############################################
# Subnet Maps (output of subnets module)
#############################################

variable "public_subnet_ids_map" {
  type        = map(string)
  description = "Map of public subnet IDs keyed by AZ key"
}

variable "private_subnet_ids_map" {
  type        = map(string)
  description = "Map of private subnet IDs keyed by AZ key"
}

variable "nonroutable_subnet_ids_map" {
  type        = map(string)
  description = "Map of non-routable subnet IDs keyed by AZ key"
}

#############################################
# IGW & NAT Inputs (Final Simplified Version)
#############################################

variable "igw_id" {
  type        = string
  description = "Internet Gateway ID"
}

variable "public_nat_ids_map" {
  type        = map(string)
  description = "Map of Public NAT Gateways (used for private subnets)"
}

variable "private_nat_ids_map" {
  type        = map(string)
  description = "Map of Private NAT Gateways (used for non-routable subnets)"
}

#############################################
# Route Definitions (from tfvars)
#############################################

variable "route_tables" {
  description = "Routing config for public, private, and non-routable route tables"

  type = object({
    public = object({
      routes = list(object({
        cidr   = string
        target = string    # igw / nat
      }))
    })

    private = object({
      routes = list(object({
        cidr   = string
        target = string    # nat only
        az_key = string
      }))
    })

    nonroutable = object({
      routes = list(object({
        cidr   = string
        target = string    # nat only
        az_key = string
      }))
    })
  })
}

#############################################
# Behavior Controls
#############################################

variable "skip_existing_routes" {
  type        = bool
  description = "Skip creating routes that already exist in AWS route tables"
  default     = true
}
