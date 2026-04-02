data "aws_availability_zones" "available" {
    state = "available"
}

####VPC####

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cider
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.cluster_name}-vpc"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
}

#### Internet Gateway ####

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.cluster_name}-igw"
    }
}


# public subnets

resource "aws_subnet" "public" {
    count = 2
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(var.vpc_cider, 8, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true
    

    tags = {
        Name = "${var.cluster_name}-public-subnet-${count.index + 1}"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        "kubernetes.io/role/elb" = "1"
    }
}

# private subnets  (for Worker Nodes)

resource "aws_subnet" "private" {
    count = 2
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    

    tags = {
        Name = "${var.cluster_name}-private-subnet-${count.index + 1}"
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        "kubernetes.io/role/internal-elb" = "1"
    }
}


# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.cluster_name}-nat-eip"
  }
}

# NAT Gateway (allows private subnet nodes to reach internet)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.cluster_name}-nat"
  }
  depends_on = [aws_internet_gateway.main]
}

# Route Table: Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "${var.cluster_name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table: Private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = { Name = "${var.cluster_name}-private-rt" }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
