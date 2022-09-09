# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr

  tags = {
    Name        = "${var.environment}_vpc"
    Environment = var.environment
  }
}

# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.environment}_internet_gateway"
    Environment = var.environment
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  depends_on              = [aws_internet_gateway.internet_gateway]
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}_public_subnet"
    Environment = "${var.environment}"
  }
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.environment}_public_route_table"
    Environment = "${var.environment}"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# Route table association for Public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.internet_gateway]
  vpc        = true
}

# NAT
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)

  tags = {
    Name        = "${var.environment}_NAT_gateway"
    Environment = "${var.environment}"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}_private_subnet"
    Environment = "${var.environment}"
  }
}

# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.environment}_private_route_table"
    Environment = "${var.environment}"
  }
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Route table association for Private subnet
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

# Public Security Group of VPC
resource "aws_security_group" "public_sg" {
  name        = "${var.environment}_public_sg"
  description = "Default SG to allow traffic into the Public Subnet"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]

  ingress {
    description      = "TLS from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.default_internet_cidr
  }

    ingress {
      description      = "SSH from Internet"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = var.default_internet_cidr
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.default_internet_cidr
  }

  tags = {
    Name        = "${var.environment}_public_sg"
    Environment = "${var.environment}"
  }
}

# Private Security Group of VPC
resource "aws_security_group" "private_sg" {
  name        = "${var.environment}_private_sg"
  description = "Default SG to allow traffic into the Private Subnet"
  vpc_id      = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]

  ingress {
    description      = "TLS from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.public_subnets_cidr
  }

    ingress {
      description      = "SSH from Internet"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = var.public_subnets_cidr
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}_private_sg"
    Environment = "${var.environment}"
  }
}

##########EC2##############

# Key pair used for logging to EC2

resource "tls_private_key" "ec2_private_key" {
     algorithm = "RSA"
}

resource "aws_key_pair" "ec2_ssh_key" {
      key_name   = "${var.environment}_ec2_ssh_key"
      public_key = tls_private_key.ec2_private_key.public_key_openssh
}

# Creating ssm parameter to store ssh key for ec2
resource "aws_ssm_parameter" "ec2_private_ssh_key" {
  name  = "${var.environment}_ec2_private_ssh_key"
  type  = "String"
  value = tls_private_key.ec2_private_key.private_key_pem
}

# Creating ec2 instance
resource "aws_instance" "nginx_web_server" {
  count         = 1
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2_ssh_key.key_name
  subnet_id     = aws_subnet.private_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  user_data = <<EOF
#! /bin/bash
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo docker run -i -t -d -p80:80 --name demo-nginx nginx
EOF

  depends_on = [
    aws_subnet.private_subnet
  ]

  tags = {
    Name        = "${var.environment}_private_ec2_instance"
    Environment = "${var.environment}"
  }
}

# Landing zone
# Creating ec2 instance
resource "aws_instance" "landing_zone" {
  count         = 1
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2_ssh_key.key_name
  subnet_id     = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  user_data = <<EOF
#! /bin/bash
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo docker run -i -t -d -p80:80 --name demo-nginx nginx
EOF

    depends_on = [
      aws_subnet.public_subnet
    ]

  tags = {
    Name        = "${var.environment}_public_ec2_instance"
    Environment = "${var.environment}"
  }
}

########Load Balancer#######
resource "aws_lb" "app_load_balancer" {
  name               = "${var.environment}-app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  enable_deletion_protection = false  # Set this to true on production/staging environment

  tags = {
    Name        = "${var.environment}-app-load-balancer"
    Environment = "${var.environment}"
  }
}

######RDS################

