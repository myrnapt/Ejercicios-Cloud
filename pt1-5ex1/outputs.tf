#Nos devuelve los IDs y las IPs de las instancias publicas
output "public_instances" {
  value = [
    for i in aws_instance.publicas : {
      id        = i.id
      private_ip = i.private_ip
      public_ip  = i.public_ip
    }
  ]
}

# '' '' instancias privadas 
output "private_instances" {
    value = [
    for i in aws_instance.privadas : {
      id         = i.id
      private_ip = i.private_ip
      public_ip  = i.public_ip
    }
  ]
}

# Output del bucket
output "s3_bucket_name" {
  description = "Nombre del bucket S3 si se ha creado"
  value       = var.create_s3_bucket ? aws_s3_bucket.bucket_s3[0].bucket : "No se ha creado el bucket S3"   
}
