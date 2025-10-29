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


Control núm.: Pt1.5
Data:  29/10/2025


Professors: Héctor Alarcón i Pedro Durán

Nom i cognoms alumne:


Pas 1: Configuració inicial
Crear un fitxer variables.tf amb les següents variables:


region: Regió.
project_name: Nom del projecte.
instance_count: Defineix quantes instàncies per subnet.
subnet_count: Defeneix quantes subnets hi ha per cada tipus (privat i públiques).
instance_type: El tipus de la instància, generalment t3.micro.
instance_ami: Cadena de text representant la imatge d'AWS.
create_s3_bucket: (per crear bucket S3 condicionalment)
vpc_cidr: Xarxa en notació CIDR per la xarxa: 10.0.0.0 amb màscara 255.255.0.0.
my_ip: Xarxa en notació CIDR que representa la xarxa la qual es permet conexió SSH. Per defecte seran totes les xarxes.


Crear un fitxer provider.tf on es defineixi el proveïdor fent servir la variable region.



Pas 2: Xarxa i subxarxes
Crear una VPC amb un CIDR. Amb la variable vpc_cidr.


Crear 2 subxarxes públiques i 2 subxarxes privades for_each o count. Heu d'utilitzar la variable subnet_count.
Crear un Internet Gateway (IGW) i associar-lo a les subxarxes públiques.


Pas 3: Instàncies EC2
Crear un Security Group que:
Permet HTTP (port 80) des de qualsevol IP
Permet SSH (port 22) només des de la IP de l'institut o casa vostra.
No permet tràfic ICMP desde cap IP que no sigui interna de la VPC.
Permeti tot el tràfic a qualsevol IP.


Crear les instàncies públiques i privades utilitzant count o for_each.
Assignar correctament les instàncies a les subxarxes públiques i privades.

Pas 4: Bucket S3 condicional
Crear un bucket S3 només si la variable create_s3_bucket està activada (True). S'ha d'utilitzar condicionals per fer això.


Pas 5: Outputs
Crear outputs en el fitxer outputs.tf que:


Retorni les ID de les instàncies, amb les seves IP públiques i les seves IP privades.


El nom del bucket s3 creat en cas que s'hagi creat.

Requisits addicionals
Afegir tags amb el nom del projecte a tots els recursos.


Documentar cada recurs amb un comentari explicatiu.


Fer servir depends_on quan sigui necessari per gestionar dependències.





Estructura de carpetes a GitHub:

📁 exercicis
├── 📁 pt-1-5
│   ├── 📁 assets
│   │   └── 🖼️ Imatges (opcionales, diagrama de la infraestructura, captures, etc.)
│   ├── 📄 README.md          # Explicació de l'exercici i instruccions pas a pas
│   ├── 📄 main.tf            # Fitxer principal amb els recursos Terraform
│   ├── 📄 variables.tf       # Variables definides per l'exercici
│   ├── 📄 outputs.tf         # Outputs definits per l'exercici
│   └── 📄 provider.tf        # Configuració del provider AWS


