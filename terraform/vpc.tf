resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = merge(var.tags, {Name = "${var.env_name}-vpc"})
  lifecycle {
    prevent_destroy = false # since this is a personal project
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {Name = "${var.env_name}-igw"})
}

# NAT

resource "aws_eip" "nat" {
  tags = merge(var.tags, {Name = "${var.env_name}-nat-eip"})
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.pub_sub)[0].id
  tags = merge(var.tags, {Name = "${var.env_name}-nat"})
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# PUB SUB

resource "aws_subnet" "pub_sub" {
  for_each = {for i,az in local.azs : az => local.public_subnets[i] }
  vpc_id     = aws_vpc.main.id  
  cidr_block = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true
  tags = merge(var.tags, {Name = "${var.env_name}-pub-sub-${each.key}"})
}

# PVT SUB

resource "aws_subnet" "pvt_sub" {
  for_each = {for i,az in local.azs : az => local.private_subnets[i] }
  vpc_id     = aws_vpc.main.id  
  cidr_block = each.value
  availability_zone = each.key
  tags = merge(var.tags, {Name = "${var.env_name}-pvt-sub-${each.key}"})
}

# PUB RT

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {Name = "${var.env_name}-pub-rt"})
}

resource "aws_route_table_association" "pub-rt-assoc" {
  for_each = aws_subnet.pub_sub
  subnet_id      = each.value.id
  route_table_id = aws_route_table.pub_rt.id
}

# PVT RT

resource "aws_route_table" "pvt_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(var.tags, {Name = "${var.env_name}-pvt-rt"})
}

resource "aws_route_table_association" "pvt-rt-assoc" {
  for_each = aws_subnet.pvt_sub
  subnet_id      = each.value.id
  route_table_id = aws_route_table.pvt_rt.id
}
