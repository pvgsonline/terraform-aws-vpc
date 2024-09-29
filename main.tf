#VPC creation
resource "aws_vpc" "main" {
  cidr_block       = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.common_tags ,{
    Name = local.resource_name
  }
  )
  }


#Internet gateway creation
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags ,{
    Name = local.resource_name
  }
  )
}