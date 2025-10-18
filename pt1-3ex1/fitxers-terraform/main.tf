# configurar proveedor
provider "aws" {
        region = "us-east-1"
}
# crear instancia 
resource "aws_instance" "hello_world" {
    instance_type = "t3.micro"              # Tipo de instancia gratuita
    ami           = "ami-052064a798f08f0d3" # Amazon Linux 2 AMI

    tags = {
            Name = "Terraform-ex1"
    }
}