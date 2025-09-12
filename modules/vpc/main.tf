provider "aws" {
  region = var.region
}

# -----------------------
# VPC
# -----------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }, var.tags)
}

# -----------------------
# Internet Gateway
# -----------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
  }, var.tags)
}

# -----------------------
# Public Subnets
# -----------------------
resource "aws_subnet" "public" {
  for_each            = zipmap(var.azs, var.public_subnet_cidrs)
  vpc_id              = aws_vpc.main.id
  cidr_block          = each.value
  availability_zone   = each.key
  map_public_ip_on_launch = true

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-public-${each.key}"
    Environment = var.environment
    Project     = var.project_name
  }, var.tags)
}

# -----------------------
# Private Subnets
# -----------------------
resource "aws_subnet" "private" {
  for_each          = zipmap(var.azs, var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  map_public_ip_on_launch = false

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-private-${each.key}"
    Environment = var.environment
    Project     = var.project_name
  }, var.tags)
}

# -----------------------
# Public Route Table
# -----------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge({
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
  }, var.tags)
}

# Associate public subnets with route table
resource "aws_route_table_association" "public_assoc" {
  for_each      = aws_subnet.public
  subnet_id     = each.value.id
  route_table_id = aws_route_table.public.id
}
