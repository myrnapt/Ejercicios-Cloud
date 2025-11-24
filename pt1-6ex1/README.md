Generalitat de Catalunya
Departament d’Educació
INS Provençana


Mòdul OPT: 
Cloud Computing
Curs 
2025-2026


Departament d’Informàtica

Grup: ASIX2
A1 RA1 RA2
Nota:


Control núm.: Pt1.6
Data: 


Professors: Héctor Alarcón i Pedro Durán



Nom i cognoms alumne:

🎯 Objectiu de l'Exercici

Desplegar una arquitectura de xarxa segura a AWS (VPC amb subxarxes públiques i privades) utilitzant Terraform. La infraestructura ha de ser escalable per permetre la creació de N instàncies privades (controlades per una variable) i ha de permetre l'accés segur i transparent a aquestes instàncies a través d'un Bastion Host, utilitzant ProxyJump des de la màquina local.


🏛️ Visió General de l'Arquitectura

Aquest projecte desplega una arquitectura de núvol segura, comuna i escalable.

Els components principals són:

1. 🌐 Xarxa (VPC):
1 VPC (10.0.0.0/16).
1 Subxarxa Pública (per al Bastió), amb un Internet Gateway.
N Subxarxes Privades (controlades per la variable private_instance_count). Els seus blocs CIDR es calculen automàticament amb la funció cidrsubnet (p.ex. 10.0.2.0/24, 10.0.3.0/24, ...). Totes utilitzen un NAT Gateway per a l'accés a Internet sortint.

2. 🖥️ Instàncies EC2:
1 Bastion Host (EC2) a la subxarxa pública amb una IP Elàstica (EIP) fixa.
N Servidors Privats (EC2), cadascun en una subxarxa privada diferent. Les subxarxes es distribueixen (roten) automàticament entre les Zones de Disponibilitat (AZs) definides.

3.🔒 Seguretat (Security Groups):
Bastion SG: Permet connexions SSH (port 22) des de la teva IP (controlada per la variable allowed_ip). Permet sortides SSH (port 22) cap a les subxarxes privades.
Private SG: Només accepta connexions SSH (port 22) des del Security Group del Bastió i des de si mateix (per a la comunicació entre servidors privats).

4. 🔑 Gestió de Claus (ProxyJump):
Es generen 1 + N parells de claus SSH (1 per al Bastió i 1 per a cadascuna de les N instàncies privades).
Totes les claus privades (.pem) es descarreguen a la teva màquina local.
L'accés es realitza mitjançant ProxyJump: el teu client SSH local utilitza bastion.pem per obrir un túnel al bastió, i després utilitza la clau corresponent (private-1.pem, private-2.pem, ... private-N.pem) per autenticar-se directament contra les màquines privades a través d'aquest túnel.
El Bastion Host no emmagatzema les claus privades dels servidors (excepte la seva).

5. 🪣 Emmagatzematge (S3):
Es crea un bucket S3 privat.
Totes les claus públiques (.pub) generades (Bastió + N privades) s'emmagatzemen en aquest bucket com a còpia de seguretat.



🚀 Instruccions d'Ús

1. Desplegament

Primer, inicialitza Terraform i desplega la infraestructura.

# Inicialitza els proveïdors
terraform init

# Planifica i aplica els canvis.
terraform apply

⭐ Escalabilitat: Pots canviar el nombre d'instàncies privades modificant la variable private_instance_count. El valor per defecte és 2.

Per exemple, per desplegar 3 instàncies privades:

terraform apply -var="private_instance_count=3"


2. Configuració Local (Post-Apply)

En finalitzar, terraform apply haurà creat diversos fitxers al teu directori:

    bastion.pem
    private-1.pem
    private-2.pem
    ... (tants fitxers private-N.pem com hagis indicat a private_instance_count)
    ssh_config_per_connect.txt

Per automatitzar la configuració local, utilitza l'script setup_ssh.sh (que has de tenir al mateix directori).

# Dona permisos d'execució a l'script
chmod +x setup_ssh.sh

# Executa l'script
./setup_ssh.sh

Aquest script farà el següent automàticament:

Mourà totes les claus .pem generades al teu directori ~/.ssh/.
Assignarà els permisos correctes (chmod 400).
Afegirà la configuració del ProxyJump del fitxer ssh_config_per_connectar.txt al teu ~/.ssh/config (sense duplicar-ho si ja existeix).

3. Connexió

Un cop executat l'script, ja pots connectar-te directament a qualsevol recurs des del teu terminal local.

# Per connectar a la màquina privada 1 (a través del bastió)
ssh private-1

# Per connectar a la màquina privada 2 (a través del bastió)
ssh private-2

# ... i així successivament per a totes les instàncies creades
ssh private-N

# Per connectar directament al bastió
ssh bastion

🧹 Neteja

Per destruir tota la infraestructura i evitar costos, executa (recorda passar les mateixes variables que a l'apply, especialment si has canviat private_instance_count):

terraform destroy -var="private_instance_count=3"


Estructura de carpetes a GitHub:

📁 exercicis
├── 📁 pt-1-6
│   ├── 📁 assets
│   │   └── 🖼️ Imatges (opcionals, diagrama de la infraestructura, captures, etc.)
│   ├── 📄 README.md          # Explicació de l'exercici i instruccions pas a pas
│   ├── 📄 main.tf            # Fitxer principal amb els recursos Terraform
│   ├── 📄 variables.tf       # Variables definides per l'exercici
│   ├── 📄 outputs.tf         # Outputs definits per l'exercici
│   └── 📄 provider.tf        # Configuració del provider AWS
│   └── 📄 ssh_config.tpl     # Plantilla per a la configuració SSH dinàmica
│   └── 📄 setup_ssh.sh       # Script per automatitzar la configuració SSH local

Referències
Terraform - AWS Resource: NAT Gateway
Terraform - AWS Resource: EIP
Terraform - AWS Resource: aws_eip_association
Terraform - Resource: local_file
Terraform - AWS Resource: aws_key_pair
Terraform - TLS Resource: tls_private_key
Terraform - templatefile Function
Terraform - AWS Resource: aws_s3_bucket_ownership_controls
Terraform - AWS Resource: aws_s3_object
