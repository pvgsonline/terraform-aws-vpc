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
resource "aws_internet_gateway" "igw" {
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

#create subnet groups for database

resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database[*].id

  tags = merge (var.common_tags,{
    Name = local.resource_name
  }
  )
}

#allocate elastic ip

resource "aws_eip" "nat" {
  domain   = "vpc"
}

#create a NAT gateway

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge (var.common_tags ,{
    Name = local.resource_name
  }
  )

  depends_on = [aws_internet_gateway.igw]

}

#create routing tables

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_name}-database"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_name}-private"
  }
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_name}-database"
  }
}

#create routes for the routing tables

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

#subnet association to route tables

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr) 
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr) 
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr) 
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}




