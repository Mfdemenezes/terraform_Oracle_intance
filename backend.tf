# =============================================================================
# TERRAFORM BACKEND CONFIGURATION - ORACLE OBJECT STORAGE
# =============================================================================

# IMPORTANTE: Execute primeiro com backend local para criar o bucket
# Depois descomente a configuração abaixo e execute: terraform init -migrate-state

# Configuração do backend remoto (descomente após criar bucket)
/*
terraform {
  backend "s3" {
    # Oracle Object Storage S3-compatible endpoint
    endpoint                    = "https://NAMESPACE.compat.objectstorage.sa-saopaulo-1.oraclecloud.com"
    bucket                     = "PROJETO-AMBIENTE-terraform-state"
    key                        = "terraform.tfstate"
    region                     = "sa-saopaulo-1"

    # Configurações S3
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style           = true

    # Usar Customer Secret Keys do Object Storage
    # Configure no GitHub Secrets:
    # AWS_ACCESS_KEY_ID = Customer Secret Key Access Key
    # AWS_SECRET_ACCESS_KEY = Customer Secret Key Secret
  }
}
*/

# INSTRUÇÕES PARA CONFIGURAR BACKEND REMOTO:

# 1. Execute primeiro deploy para criar bucket:
#    terraform init
#    terraform apply

# 2. Veja outputs do bucket criado:
#    terraform output bucket_info

# 3. Configure Customer Secret Keys no Oracle Cloud:
#    - Vá em Identity > Users > seu_user > Customer Secret Keys
#    - Crie nova chave e guarde Access Key e Secret Key

# 4. Configure GitHub Secrets:
#    AWS_ACCESS_KEY_ID = sua_access_key
#    AWS_SECRET_ACCESS_KEY = sua_secret_key

# 5. Descomente configuração backend acima e atualize:
#    - NAMESPACE: namespace do seu tenancy
#    - PROJETO-AMBIENTE: nome do bucket criado

# 6. Migre state para backend remoto:
#    terraform init -migrate-state

# 7. Confirme que state foi migrado:
#    # O arquivo terraform.tfstate local será removido
#    # State ficará no Object Storage

# Para verificar namespace:
# oci os ns get