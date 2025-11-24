#Especificamos el proveedor AWS y la version de terraform
terraform {
  required_providers {
    aws = {
    source = "hashicorp/aws" 
    version = "~> 5.0" 
    }
  }
}

#Especificamos la region donde se desplegaran los recursos
provider "aws" {
  region = var.region
}