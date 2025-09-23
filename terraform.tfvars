# =============================================================================
# TERRAFORM ORACLE CLOUD INFRASTRUCTURE - CONFIGURAÇÕES
# =============================================================================

# Configurações do Projeto
project_name = "meu-projeto"
environment  = "dev"

# Configurações das Instâncias
instance_count      = 2
instance_shape      = "VM.Standard.E2.1.Micro"
create_reserved_ip  = true

# Configurações do Ambiente Oracle Cloud
region              = "sa-saopaulo-1"
availability_domain = "VKxG:SA-SAOPAULO-1-AD-1"

# Usar infraestrutura existente
use_existing_vpc = true

# Configurações das Ferramentas
install_dev_tools       = true
docker_compose_version  = "2.23.3"

# Tags personalizadas
tags = {
  "Environment" = "desenvolvimento"
  "Project"     = "meu-projeto-dev"
  "Owner"       = "marcelo"
  "ManagedBy"   = "terraform"
  "Purpose"     = "development-instances"
}