# =============================================================================
# TERRAFORM ORACLE CLOUD INFRASTRUCTURE - VARIABLES
# =============================================================================

# Configurações do Projeto
variable "project_name" {
  description = "Nome do projeto (será usado no nome das instâncias)"
  type        = string
  default     = "dev"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Configurações da Instância
variable "instance_count" {
  description = "Número de instâncias a serem criadas"
  type        = number
  default     = 1
}

variable "instance_shape" {
  description = "Shape da instância Oracle Cloud"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "create_reserved_ip" {
  description = "Criar IP público reservado para as instâncias"
  type        = bool
  default     = true
}

# Configurações do Compartment
variable "tenancy_ocid" {
  description = "OCID do tenancy Oracle Cloud"
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaau5s2npsmtgfc2xjj54ladpii4bbapz42vbvalqyyyrfim2bvyrta"
}

variable "compartment_ocid" {
  description = "OCID do compartment (usando tenancy como padrão)"
  type        = string
  default     = ""
}

# Configurações de Rede
variable "availability_domain" {
  description = "Availability Domain"
  type        = string
  default     = "VKxG:SA-SAOPAULO-1-AD-1"
}

variable "region" {
  description = "Região Oracle Cloud"
  type        = string
  default     = "sa-saopaulo-1"
}

# Configurações SSH
variable "ssh_public_key_path" {
  description = "Caminho para a chave SSH pública"
  type        = string
  default     = "~/.ssh/oracle/ssh-key-2025-09-15.key.pub"
}

# Configurações da Imagem
variable "instance_image_ocid" {
  description = "OCID da imagem Ubuntu 22.04"
  type        = string
  default     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaqmun6z7danuvgqpnrmob35gav7hsczbfgdtn7q6tqlxgdhwlndsq"
}

# Configurações de VPC (usar existente)
variable "use_existing_vpc" {
  description = "Usar VPC existente ao invés de criar nova"
  type        = bool
  default     = true
}

variable "existing_vcn_ocid" {
  description = "OCID da VPC existente"
  type        = string
  default     = "ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaahy4hlvyabetcaffdvof3ul2eoa3cwddzofkjzgxwqw2xier4zaua"
}

variable "existing_subnet_ocid" {
  description = "OCID da subnet existente"
  type        = string
  default     = "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaabgjt4llgv4bnmqob4sklp4sbz3hnxwo744a6zdbpsbzbe55pxbea"
}

# User Data Script
variable "install_dev_tools" {
  description = "Instalar ferramentas de desenvolvimento (Git, Docker, Docker Compose)"
  type        = bool
  default     = true
}

variable "docker_compose_version" {
  description = "Versão do Docker Compose a ser instalada"
  type        = string
  default     = "2.23.3"
}

# Tags
variable "tags" {
  description = "Tags a serem aplicadas aos recursos"
  type        = map(string)
  default = {
    "Environment" = "dev"
    "Project"     = "terraform-oracle-dev"
    "ManagedBy"   = "terraform"
  }
}