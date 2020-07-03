# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  profile = "default"
  region  = "us-east-1"
}

# Parameters
variable "EnvironmentName" {
  type = string
  default = "example"
}

variable "CidrBlocks" {
  type = list(string)
  default = [
            "0.0.0.0/0",
            "10.0.0.0/16",
            "10.0.0.0/24",
            "10.0.1.0/24"
  ]
}

# Data



# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = var.CidrBlocks[1]
  tags = {
    Name = var.EnvironmentName
  }
}


# Internet Gateway & VPCGatewayAttachment
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = var.EnvironmentName
    Environment = var.EnvironmentName
  }
}

# NatGateway & EIP
resource "aws_eip" "public_subnet_eip" {
  vpc = true
  tags = {
    Name = "{var.EnvironmentName} - EIP"
    Environment = var.EnvironmentName
  }
}

resource "aws_nat_gateway" "priv_subnet_nat" {
  allocation_id = aws_eip.public_subnet_eip.id
  subnet_id = aws_subnet.private.id
  tags = {
    Name = "{var.EnvironmentName} - NAT"
    Environment = var.EnvironmentName
  }
}

# Subnets
resource "aws_subnet" "public" {
  cidr_block = var.CidrBlocks[2]
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "{var.EnvironmentName} - Public"
    Environment = var.EnvironmentName
  }
}

resource "aws_subnet" "private" {
  cidr_block = var.CidrBlocks[3]
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "{var.EnvironmentName} - Private"
    Environment = var.EnvironmentName
  }
}

# Routing
resource "aws_route_table" "public_route_table" {

  vpc_id = aws_vpc.example.id

  route {
    cidr_block = var.CidrBlocks[0]
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.EnvironmentName} - Public"
    Environment = var.EnvironmentName
  }
}

