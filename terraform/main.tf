# terraform/main.tf
provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "toye_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TOYE-VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.toye_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.toye_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.toye_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "Web Security Group"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-07c8c1b18ca66bb07"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "Web Server"
  }
}
