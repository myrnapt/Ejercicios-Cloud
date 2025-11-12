# creamos una red virtual privada
resource "aws_vpc" "vpc_01" {
  cidr_block = var.vpc_cidr
  tags = { 
    Name = "${var.project_name}_vpc"
    }
}


# Creamos las subredes
resource "aws_subnet" "subnet_publicas" {
  count                   = var.subnet_count #cantidad de subnets a crear
  vpc_id                  = aws_vpc.vpc_01.id #le decimos que lo haga dentro de la VPC creada
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index) 
  map_public_ip_on_launch = true #que tenga ip publica

  tags = {
    Name = "${var.project_name}_subnet_publica_${count.index + 1}"
  }
}


resource "aws_subnet" "subnet_privadas" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  map_public_ip_on_launch = false #no tiene ip publica
  
  tags = {
    Name = "${var.project_name}_subnet_privada_${count.index}"
  }
}

#Creamos las itenrnet gateways
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc_01.id # la asociamos a la VPC creada
  tags = {
    Name = "${var.project_name}_gateway"
  }
}

#Creamos la tabla de rutas 
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

#Asociamos la tabla de rutas a las subnets publicas
resource "aws_route_table_association" "ruta_subnet_publica" {
  count          = length(aws_subnet.subnet_publicas) #cantidad de subnets creadas
  subnet_id      = aws_subnet.subnet_publicas[count.index].id
  route_table_id = aws_route_table.tabla_rutas_publicas.id
}

#Grupo de seguridad
resource "aws_security_group" "grupo_seguridad" {
  name = "${var.project_name}_grupo_seguridad"
  vpc_id = aws_vpc.vpc_01.id
  tags = {
    Name = "${var.project_name}_grupo_seguridad"
  }
  
  #Reglas de entrada
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.my_ip]
    } #permite http desde cualquier IP

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    } #permite ssh desde la ip del instituto o de casa
  
  ingress {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = [var.vpc_cidr]
    } #No permite trafico ICMP de iPs que no sean de la vpc 
  
  #Reglas de salida
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.my_ip]
    } #permite salidas hacia cualquier IP
}

#Creamos las instancias EC2
# Instancias públicas
resource "aws_instance" "publicas" {
  count                  = length(aws_subnet.subnet_publicas) * var.instance_count
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_publicas[floor(count.index / var.instance_count)].id
  vpc_security_group_ids = [aws_security_group.grupo_seguridad.id]
  key_name               = "vockey"

  tags = {
    Name = "publica-${floor(count.index / var.instance_count)}-${count.index % var.instance_count}"
  }
}

# Instancias privadas
resource "aws_instance" "privadas" {
  count                  = length(aws_subnet.subnet_privadas) * var.instance_count #numero de instancias por subnet (en este caso 2*3 = 6)
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_privadas[floor(count.index / var.instance_count)].id 
  vpc_security_group_ids = [aws_security_group.grupo_seguridad.id]
  key_name               = "vockey"

  tags = {
    Name = "privada-${floor(count.index / var.instance_count)}-${count.index % var.instance_count}"
  }
}

#Creamos el bucket S3
resource "aws_s3_bucket" "bucket_s3" {
  count  = var.create_s3_bucket ? 1 : 0 #solo lo creamos si la variable es true
  bucket = "${var.project_name}-bucket"
  tags = {
    Name = "${var.project_name}-bucket"
  }
}

