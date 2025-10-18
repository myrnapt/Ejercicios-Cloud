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
