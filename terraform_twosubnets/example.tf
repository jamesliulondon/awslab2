# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  profile = "default"
//  region  = "us-east-1"
  region = "eu-west-2"
}

# Parameters
variable "EnvironmentName" {
  type = string
  default = "example"
}

variable "KeyName" {
  type = string
  default = "/Users/jamliu1/.ssh/nationwide_rsa.pub"
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
data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "latest-amazon" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "description"
    values = ["Amazon Linux AMI*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

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
    Name = "${var.EnvironmentName} - EIP"
    Environment = var.EnvironmentName
  }
}

resource "aws_nat_gateway" "priv_subnet_nat" {
  allocation_id = aws_eip.public_subnet_eip.id
  subnet_id = aws_subnet.private.id
  tags = {
    Name = "${var.EnvironmentName} - NAT"
    Environment = var.EnvironmentName
  }
}

# Subnets
resource "aws_subnet" "public" {
  cidr_block = var.CidrBlocks[2]
  vpc_id = aws_vpc.example.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.EnvironmentName} - Public"
    Environment = var.EnvironmentName
  }
}

resource "aws_subnet" "private" {
  cidr_block = var.CidrBlocks[3]
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "${var.EnvironmentName} - Private"
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

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security
resource "aws_security_group" "public" {
  name        = "allow_ssh"
  description = "Allow SSH traffic"
  vpc_id      = "${aws_vpc.example.id}"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


# Single Instance

resource "aws_instance" "single" {
  ami = data.aws_ami.latest-amazon.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  key_name = var.KeyName
  security_groups = [aws_security_group.public.id]
}


# Output
output "ami" {
  value = data.aws_ami.latest-amazon.id
}