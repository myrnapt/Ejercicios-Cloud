provider "aws" {
  region = "us-east-1"
}

# Crear la VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-ex2"
  }
}

# Crear las tres subnets (todas en us-east-1a)
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.32.0/25"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "SubnetA"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.30.0/23"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "SubnetB"
  }
}

resource "aws_subnet" "subnet_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.33.0/28"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "SubnetC"
  }
}

# Crear 2 instancias en cada subnet
resource "aws_instance" "subnet_a_instances" {
  count         = 2
  ami           = "ami-052064a798f08f0d3"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet_a.id

  tags = {
    Name = "A-${count.index + 1}"
  }
}

resource "aws_instance" "subnet_b_instances" {
  count         = 2
  ami           = "ami-052064a798f08f0d3"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet_b.id

  tags = {
    Name = "B-${count.index + 1}"
  }
}

resource "aws_instance" "subnet_c_instances" {
  count         = 2
  ami           = "ami-052064a798f08f0d3"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet_c.id

  tags = {
    Name = "C-${count.index + 1}"
  }
}


# Grup de seguretat
resource "aws_security_group" "public_sg" {
  name        = "grupo_seguridad"
  description = "Permitir acceso SSH desde cualquier parte, transito ICMP solo dentro de la VPC y permitir todo el trafico salientel"
  vpc_id      = aws_vpc.vpc_03.id

  # Ingress SSH des de qualsevol lloc
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP (ping) només des de dins de la VPC
  ingress {
    description = "ICMP des de VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.vpc_03.cidr_block]
  }
}

# Regla de salida
resource "aws_security_group_rule" "egress_todo" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.grupo_seguridad.id
}

