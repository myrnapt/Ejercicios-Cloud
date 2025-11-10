resource "aws_vpc" "vpc_01" {
  cidr_block = var.vpc_cidr
}


# Creamos subredes
resource "aws_subnet" "subnet_publicas" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}_subnet_publica_${count.index + 1}"
  }
}


resource "aws_subnet" "subnet_privadas" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  map_public_ip_on_launch = false
  
  tags = {
    Name = "${var.project_name}_subnet_privada_${count.index}"
  }
}

#Declaramos gateway y la asociaciamos a las subnets publicas
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc_01.id
}

resource "aws_route_table" "tabla_rutas_publicas" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id     
  }

  tags = {
    Name = "${var.project_name}_tabla_rutas_publica"
  }
}

resource "aws_route_table_association" "ruta_subnet_publica" {
  count          = length(aws_subnet.subnet_publicas)
  subnet_id      = aws_subnet.subnet_publicas[count.index].id
  route_table_id = aws_route_table.tabla_rutas_publicas.id
}

#Grupo de seguridad
resource "aws_security_group" "grupo_seguridad" {
  name = "${var.project_name}_grupo_seguridad"
  vpc_id = aws_vpc.vpc_01.id
  
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.my_ip]
    }

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.my_ip]
    }      
  
  ingress {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = [var.my_ip]
    }      
  
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.my_ip]
    }
}

#Instancias EC2

