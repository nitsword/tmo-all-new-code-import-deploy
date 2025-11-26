###########################################
# Subnets module — 3 groups:
#   public
#   private
#   nonroutable
###########################################

resource "aws_subnet" "public" {
  for_each = try(var.subnets.public, {})

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    { Name = "${var.name_prefix}-public-${each.key}" },
    var.tags
  )
}

resource "aws_subnet" "private" {
  for_each = try(var.subnets.private, {})

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    { Name = "${var.name_prefix}-private-${each.key}" },
    var.tags
  )
}

resource "aws_subnet" "nonroutable" {
  for_each = try(var.subnets.nonroutable, {})

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    { Name = "${var.name_prefix}-nonroutable-${each.key}" },
    var.tags
  )
}
