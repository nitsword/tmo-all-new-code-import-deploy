variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for endpoints"
}

variable "interface_subnet_ids" {
  type        = list(string)
  description = "Subnets for interface endpoints"
}

variable "gateway_route_table_ids" {
  type        = list(string)
  description = "Route table IDs for S3 gateway endpoint"
}

variable "enabled" {
  type = object({
    ssm         = bool
    ec2messages = bool
    s3          = bool
  })
  description = "Enable/disable each VPC endpoint"
}
