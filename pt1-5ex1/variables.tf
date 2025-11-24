#Declaramos varinbles que luego referenciaremos en los recursos
variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  default     = "pt1-5ex1"
}

variable "instance_count" {
  type        = number
  default     = 2
}

variable "subnet_count" {
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

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "my_ip" {
    type        = string
    default     = "0.0.0.0/0"
}
