# Configuración SSH para Bastion y servidores privados

Host bastion
  HostName ${bastion_ip}
  User ec2-user
  IdentityFile ~/.ssh/bastion.pem
  StrictHostKeyChecking no

%{ for index, ip in private_ips }
Host private-${index + 1}
  HostName ${ip}
  User ec2-user
  IdentityFile ~/.ssh/private-${index + 1}.pem
  ProxyJump bastion
  StrictHostKeyChecking no
%{ endfor }