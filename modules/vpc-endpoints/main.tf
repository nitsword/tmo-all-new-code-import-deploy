data "aws_region" "current" {}

locals {
  ssm_enabled         = var.enabled.ssm
  ec2messages_enabled = var.enabled.ec2messages
  s3_enabled          = var.enabled.s3
}

#############################################################
# SSM ENDPOINT
#############################################################

resource "aws_vpc_endpoint" "ssm" {
  count = local.ssm_enabled ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.interface_subnet_ids
  private_dns_enabled = true

  tags = {
    Name = "${var.name_prefix}-vpce-ssm"
  }
}

#############################################################
# EC2 MESSAGES
#############################################################

resource "aws_vpc_endpoint" "ec2messages" {
  count = local.ec2messages_enabled ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.interface_subnet_ids
  private_dns_enabled = true

  tags = {
    Name = "${var.name_prefix}-vpce-ec2messages"
  }
}

#############################################################
# S3 GATEWAY ENDPOINT — MUST NOT GO TO PUBLIC SUBNETS
#############################################################

resource "aws_vpc_endpoint" "s3" {
  count = local.s3_enabled ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.gateway_route_table_ids

  tags = {
    Name = "${var.name_prefix}-vpce-s3"
  }
}
