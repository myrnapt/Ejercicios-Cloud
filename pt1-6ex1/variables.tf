#Vamos a declarar todas las variables que necesitaremos referenciar en los recursos
#Variables generales del proyecto
variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  default     = "pt1-6ex1"
}

#Variables para la VPC e instnacias
variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.0.0/24"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

#Instancias
variable "private_instance_count" { #cada instancia privada tendra su propia subnet privada
  type        = number
  default     = 1
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
}

variable "instance_ami" {
  type        = string
  default     = "ami-052064a798f08f0d3" 
}

#bucket
variable "create_s3_bucket" {
  type        = bool
  default     = true
}

variable "my_ip" {
    type        = string
    default     = "2.136.30.53/32"
}

variable "azs" {
  description = "Availability Zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
}
