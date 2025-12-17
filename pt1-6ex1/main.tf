# Provider configurado en provider.tf

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Subred publica y bastion
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public"
  }
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Tabla de rutas públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route" "public_default_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Subredes privadas (una por cada instancia privada)
resource "aws_subnet" "private" {
  count = var.private_instance_count
  vpc_id            = aws_vpc.main.id
  availability_zone = var.azs[count.index % length(var.azs)]
  # Cidrsubnet: +1 para saltarse la pública
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  tags = {
    Name = "${var.project_name}-private-${count.index}"
  }
}

# Elastic IP para NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "${var.project_name}-nat"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Rutas privadas
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route" "private_default_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_assoc" {
  count          = var.private_instance_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Reglas seguridad bastion
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project_name}-bastion-sg"
  description = "SSH desde mi ip"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Reglas seguridad instancias privadas
resource "aws_security_group" "private_sg" {
  name        = "${var.project_name}-private-sg"
  description = "ssh desde solo bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generar clave bastion
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh
}

resource "local_file" "bastion_key" {
  filename        = pathexpand("~/.ssh/bastion.pem")
  content         = tls_private_key.bastion.private_key_pem
  file_permission = "0600"
}

# Generar claves privadas (una por cada instancia)
resource "tls_private_key" "private" {
  count     = var.private_instance_count
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "private" {
  count      = var.private_instance_count
  key_name   = "${var.project_name}-private-key-${count.index + 1}"
  public_key = tls_private_key.private[count.index].public_key_openssh
}

resource "local_file" "private_key" {
  count           = var.private_instance_count

  filename        = pathexpand("~/.ssh/private-${count.index + 1}.pem")
  content         = tls_private_key.private[count.index].private_key_pem
  file_permission = "0600"
}


# Instancia bastion
resource "aws_instance" "bastion" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.bastion.key_name
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

# Instancias privadas
resource "aws_instance" "private" {
  count                  = var.private_instance_count
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.private[count.index].key_name

  tags = {
    Name = "${var.project_name}-private-${count.index + 1}"
  }
}

resource "aws_s3_bucket" "key_backup" {
  bucket = "${var.project_name}-ssh-key-backup-${random_id.bucket_id.hex}"
  force_destroy = true
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

# Backup de claves públicas
resource "aws_s3_object" "bastion_pub" {
  bucket = aws_s3_bucket.key_backup.id
  key    = "bastion.pub"
  content = tls_private_key.bastion.public_key_openssh
}

resource "aws_s3_object" "private_pub" {
  count   = var.private_instance_count
  bucket  = aws_s3_bucket.key_backup.id
  key     = "private-${count.index + 1}.pub"
  content = tls_private_key.private[count.index].public_key_openssh
}

#SSH CONFIGURACIOBN
resource "local_file" "ssh_config" {
  filename = "${path.module}/ssh_config_per_connect.txt"

  content = templatefile("${path.module}/ssh_config.tpl", {
    bastion_ip  = aws_instance.bastion.public_ip
    private_ips = [for inst in aws_instance.private : inst.private_ip]
  })
}