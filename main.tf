terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Amazon-Linux-2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Get Availability Zones
data "aws_availability_zones" "available" {}

# Create a VPC
resource "aws_vpc" "techcorp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "techcorp-vpc"
  }
}

# Public Subnet 1
resource "aws_subnet" "techcorp_public_subnet_1" {
  vpc_id                  = aws_vpc.techcorp_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "techcorp-public-subnet-1"
  }
}

# Public Subnet 2
resource "aws_subnet" "techcorp_public_subnet_2" {
  vpc_id                  = aws_vpc.techcorp_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "techcorp-public-subnet-2"
  }
}

# Private Subnet 1
resource "aws_subnet" "techcorp_private_subnet_1" {
  vpc_id                  = aws_vpc.techcorp_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "techcorp-private-subnet-1"
  }
}

# Private Subnet 2
resource "aws_subnet" "techcorp_private_subnet_2" {
  vpc_id                  = aws_vpc.techcorp_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "techcorp-private-subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.techcorp_vpc.id
  tags = {
    Name = "techcorp-gateway"
  }
}

# Elastic IP for NAT Gateway 1
resource "aws_eip" "nat_1" {
  domain = "vpc"
}

# Elastic IP for NAT Gateway 2
resource "aws_eip" "nat_2" {
  domain = "vpc"
}

# Elastic IP specifically for Bastion
resource "aws_eip" "bastion_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags       = { Name = "techcorp-bastion-eip" }
}

resource "aws_eip_association" "bastion_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}

# NAT Gateway 1
resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.techcorp_public_subnet_1.id

  tags = {
    Name = "techcorp-nat_gateway_1"
  }
}

# NAT Gateway 2
resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.techcorp_public_subnet_2.id

  tags = {
    Name = "techcorp-nat_gateway_2"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "techcorp-public-rt"
  }
}

# Private Route Table 1
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }

  tags = {
    Name = "techcorp-private-rt-1"
  }
}

# Private Route Table 2
resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
  }

  tags = {
    Name = "techcorp-private-rt-2"
  }
}

# Public Subnet 1 Association
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.techcorp_public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

# Public Subnet 2 Association
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.techcorp_public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

# Private Subnet 1 Association
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.techcorp_private_subnet_1.id
  route_table_id = aws_route_table.private_1.id
}

# Private Subnet 2 Association
resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.techcorp_private_subnet_2.id
  route_table_id = aws_route_table.private_2.id
}

# Bastion Security Group
resource "aws_security_group" "bastion_sg" {
  name   = "techcorp-bastion-sg"
  vpc_id = aws_vpc.techcorp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.IP_Address]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "techcorp-bastion-sg"
  }
}

# Web Security Group
resource "aws_security_group" "web" {
  name        = "techcorp-web-sg"
  description = "Allow HTTP, HTTPS, SSH"
  vpc_id      = aws_vpc.techcorp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database Security Group
resource "aws_security_group" "db" {
  name        = "techcorp-db-sg"
  description = "Allow MySQL from Web SG and SSH from Bastion SG"
  vpc_id      = aws_vpc.techcorp_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Bastion Host EC2 instance
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.techcorp_public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_pair_name

  user_data_base64 = base64encode(templatefile("${path.module}/user_data/bastion_setup.sh", {
    ssh_username = var.ssh_username
    ssh_password = var.ssh_password
  }))

  tags = {
    Name = "bastion-host-web-server"
  }
}

# Create Web Server EC2 instance 1
resource "aws_instance" "web_1" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.techcorp_private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_pair_name

  user_data_base64 = base64encode(templatefile("${path.module}/user_data/web_server_setup.sh", {
    server_name = "Web Server 1 User Data Script"
  }))

  tags = {
    Name = "web-server-1"
  }
}

# Create Web Server EC2 instance 2
resource "aws_instance" "web_2" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.techcorp_private_subnet_2.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_pair_name

  user_data_base64 = base64encode(templatefile("${path.module}/user_data/web_server_setup.sh", {
    server_name = "Web Server 2 User Data Script"
  }))
  tags = {
    Name = "web-server-2"
  }
}

# Create Database Server EC2 instance
resource "aws_instance" "db_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type_db
  subnet_id              = aws_subnet.techcorp_private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.db.id]
  key_name               = var.key_pair_name

  user_data_base64 = base64encode(templatefile("${path.module}/user_data/db_server_setup.sh", {
    server_name = "Database Server User Data Script"
  }))
  tags = {
    Name = "database-server"
  }
}

# Create Load Balancer
resource "aws_lb" "public_lb" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets = [
    aws_subnet.techcorp_public_subnet_1.id,
    aws_subnet.techcorp_public_subnet_2.id
  ]

  tags = {
    Environment = "production"
  }
}

# Load Balancer Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "techcorp-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.techcorp_vpc.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Target Group Attachment for Web Server 1
resource "aws_lb_target_group_attachment" "web_1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_1.id
  port             = 80
}

# Target Group Attachment for Web Server 2
resource "aws_lb_target_group_attachment" "web_2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_2.id
  port             = 80
}