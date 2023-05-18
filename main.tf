#------------------------------------------------------------------------------------#
# Deploy a vpc to host this project. deployed by Paul Peniel

resource "aws_vpc" "dev-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = { Name = "${var.project_name}-vpc-${var.Environment}" }
}

resource "aws_internet_gateway" "dev-Igw" {
  vpc_id = aws_vpc.dev-vpc.id
  tags   = { Name = "${var.project_name}-Igw-${var.Environment}" }
}

resource "aws_subnet" "dev-subnet1" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = var.public_cidr[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project_name}-subnet1-${var.Environment}" }
}

resource "aws_route_table" "dev-rt" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-Igw.id
  }
  tags = { Name = "${var.project_name}-dev-rt-${var.Environment}" }
}

resource "aws_route_table_association" "dev-rt-assoc" {
  subnet_id      = aws_subnet.dev-subnet1.id
  route_table_id = aws_route_table.dev-rt.id
}

# I will deploy a security group for this project here
resource "aws_security_group" "dev-sg" {
  name        = "Default sg for CICD Pipeline project"
  description = "inbound and outbound traffic for our project infra"
  vpc_id      = aws_vpc.dev-vpc.id

  dynamic "ingress" {
    for_each = [var.ports[0], var.ports[1], var.ports[2]]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/1"]
  }

  tags = { Name = "${var.project_name}-SG-${var.Environment}" }
}

resource "aws_instance" "jenkins_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.dev-subnet1.id
  associate_public_ip_address = true
  availability_zone           = var.azs[0]
  vpc_security_group_ids      = [aws_security_group.dev-sg.id]
  user_data                   = file("jenkins.sh")
  tags                        = { Name = "${var.project_name}-Jenkins-${var.Environment}" }
}