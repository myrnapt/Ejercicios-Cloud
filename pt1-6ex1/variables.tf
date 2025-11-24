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
variable "public_subnet_count" {
  type        = number
  default     = 1
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_private" {
  type        = string
  default     =  cidrsubnet()
}

variable "private_instace_count" { #cada instancia privada tendra su propia subnet privada
  type        = number
  default     = 1
}

variable "instance_count" {
  type        = number
  default     = 2
}


variable "instance_type" {
  type        = string
  default     = "t2.micro"
}

variable "instance_ami" {
  type        = string
  default     = "ami-052064a798f08f0d3" 
}

variable "create_s3_bucket" {
  type        = bool
  default     = true
}


variable "my_ip" {
    type        = string
    default     = "2.136.30.53/32"
}
