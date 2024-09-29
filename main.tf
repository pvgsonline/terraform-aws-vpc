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

#Subnet creation
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = local.az_name[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags,{
    Name = "${local.resource_name}-public-${local.az_name[count.index]}"
  }
  )
}

resource "aws_subnet" "private" {
  count     = length(var.private_subnet_cidr)
   vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = local.az_name[count.index]
  
  tags = merge(var.common_tags,{
    Name = "${local.resource_name}-private-${local.az_name[count.index]}"
  }
  )
}

resource "aws_subnet" "database" {
  count     = length(var.database_subnet_cidr)
   vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr[count.index]
  availability_zone = local.az_name[count.index]
  
  tags = merge(var.common_tags,{
    Name = "${local.resource_name}-database-${local.az_name[count.index]}"
  }
  )
}


