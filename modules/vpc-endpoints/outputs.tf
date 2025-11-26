output "vpce_ids" {
  description = "VPC endpoint IDs"
  value = {
    ssm         = try(aws_vpc_endpoint.ssm[0].id, null)
    ec2messages = try(aws_vpc_endpoint.ec2messages[0].id, null)
    s3          = try(aws_vpc_endpoint.s3[0].id, null)
  }
}
