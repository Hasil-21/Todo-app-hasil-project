locals{
	env_region_map = {
		"dev"="ap-south-1"
		"prod"="us-east-1"
	}

	env_azs_map = {
		"dev"=["ap-south-1a","ap-south-1b"]
		"prod"=["us-east-1a","us-east-1b"]
	}

	region = lookup(local.env_region_map,var.environment,"unknown")
	name = "${var.name_prefix}-${var.environment}-${local.region}"
	azs = lookup(local.env_azs_map,var.environment,[])
}

resource "aws_vpc" "main"{
	cidr_block = var.vpc_cidr_block
	enable_dns_support = true
	enable_dns_hostnames = true

	tags = {
		Name = "${local.name}-vpc"
	}	
}

resource "aws_subnet" "public"{
	vpc_id = aws_vpc.main.id
	count = length(var.public_subnet_cidrs)
	cidr_block = var.public_subnet_cidrs[count.index]
	availability_zone = local.azs[count.index]
	map_public_ip_on_launch = true

	tags = {
		Name = "${local.name}-public-${local.azs[count.index]}"
	}
}


resource "aws_subnet" "private"{
	vpc_id = aws_vpc.main.id
	count = length(var.private_subnet_cidrs)
	cidr_block = var.private_subnet_cidrs[count.index]
	availability_zone = local.azs[count.index]
	
	tags = {
		Name = "${local.name}-private-${local.azs[count.index]}"
	}
}

resource "aws_internet_gateway" "this"{
	vpc_id = aws_vpc.main.id
	
	tags = {
		Name = "${local.name}-igw"
	}
}


resource "aws_eip" "nat"{
	count = 1
	domain = "vpc"
	
	tags = {
		Name = "${local.name}-eip"
	}
}

resource "aws_nat_gateway" "this"{
	count = 1
	subnet_id = aws_subnet.public[count.index].id 
	allocation_id = aws_eip.nat[0].id
	
	tags = {
		Name = "${local.name}-nat"
	}

	depends_on = [aws_internet_gateway.this]
}
 
resource "aws_route_table" "public"{
	vpc_id = aws_vpc.main.id
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.this.id	
	} 
	
	tags = {
		Name = "${local.name}-public-rt"
	}
}


resource "aws_route_table_association" "public"{
	count = length(var.public_subnet_cidrs)
	subnet_id = aws_subnet.public[count.index].id
	route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private"{
	vpc_id = aws_vpc.main.id

	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.this[0].id
	}

	tags = {
		Name = "${local.name}-private-rt"
	}
}


resource "aws_route_table_association" "private"{
	count = length(var.private_subnet_cidrs)
	subnet_id = aws_subnet.private[count.index].id
	route_table_id = aws_route_table.private.id
}



