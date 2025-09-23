#!/bin/bash

# =============================================================================
# SCRIPT PARA CONFIGURAR BUCKET DE STATE TERRAFORM
# =============================================================================

set -e

echo "🚀 Configurando bucket para Terraform State..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar se Oracle CLI está instalado
if ! command -v oci &> /dev/null; then
    echo -e "${RED}❌ Oracle CLI não encontrado. Instale primeiro: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm${NC}"
    exit 1
fi

# Verificar se Terraform está instalado
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform não encontrado. Instale primeiro: https://terraform.io/downloads${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Verificando configuração Oracle CLI...${NC}"

# Verificar configuração Oracle CLI
if ! oci iam region list > /dev/null 2>&1; then
    echo -e "${RED}❌ Oracle CLI não configurado. Execute: oci setup config${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Oracle CLI configurado${NC}"

# Obter namespace do tenancy
echo -e "${BLUE}🔍 Obtendo namespace do tenancy...${NC}"
NAMESPACE=$(oci os ns get --query 'data' --raw-output)
echo -e "${GREEN}✅ Namespace: ${NAMESPACE}${NC}"

# Executar terraform para criar bucket
echo -e "${BLUE}🏗️ Criando bucket com Terraform...${NC}"

# Verificar se terraform.tfvars existe
if [[ ! -f "terraform.tfvars" ]]; then
    echo -e "${RED}❌ Arquivo terraform.tfvars não encontrado!${NC}"
    echo -e "${YELLOW}💡 Copie terraform.tfvars.example e configure com seus valores${NC}"
    exit 1
fi

# Inicializar Terraform (backend local)
echo -e "${BLUE}⚙️ Inicializando Terraform...${NC}"
terraform init

# Validar configuração
echo -e "${BLUE}✅ Validando configuração...${NC}"
terraform validate

# Planejar criação
echo -e "${BLUE}📋 Planejando criação do bucket...${NC}"
terraform plan -target=oci_objectstorage_bucket.terraform_state

# Confirmar criação
echo -e "${YELLOW}❓ Deseja criar o bucket de state? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Aplicar apenas bucket
    echo -e "${BLUE}🚀 Criando bucket...${NC}"
    terraform apply -target=oci_objectstorage_bucket.terraform_state -auto-approve

    # Obter informações do bucket
    echo -e "${BLUE}📊 Obtendo informações do bucket...${NC}"
    BUCKET_NAME=$(terraform output -raw bucket_info | jq -r '.bucket_name')
    S3_ENDPOINT=$(terraform output -raw bucket_info | jq -r '.s3_endpoint')

    echo -e "${GREEN}✅ Bucket criado com sucesso!${NC}"
    echo -e "${GREEN}📦 Nome do bucket: ${BUCKET_NAME}${NC}"
    echo -e "${GREEN}🌐 Endpoint S3: ${S3_ENDPOINT}${NC}"

    # Instruções para configurar backend
    echo -e "\n${BLUE}📝 PRÓXIMOS PASSOS:${NC}"
    echo -e "${YELLOW}1. Configure Customer Secret Keys no Oracle Cloud:${NC}"
    echo -e "   - Acesse: Identity & Security > Users > [seu_usuario] > Customer Secret Keys"
    echo -e "   - Clique em 'Generate Secret Key'"
    echo -e "   - Guarde Access Key e Secret Key"

    echo -e "\n${YELLOW}2. Configure GitHub Secrets (se usando GitHub Actions):${NC}"
    echo -e "   AWS_ACCESS_KEY_ID = <sua_access_key>"
    echo -e "   AWS_SECRET_ACCESS_KEY = <sua_secret_key>"

    echo -e "\n${YELLOW}3. Atualize backend.tf:${NC}"
    echo -e "   - Substitua NAMESPACE por: ${NAMESPACE}"
    echo -e "   - Substitua PROJETO-AMBIENTE-terraform-state por: ${BUCKET_NAME}"
    echo -e "   - Descomente a configuração backend"

    echo -e "\n${YELLOW}4. Migre state para backend remoto:${NC}"
    echo -e "   terraform init -migrate-state"

    echo -e "\n${GREEN}🎉 Setup do bucket concluído!${NC}"

else
    echo -e "${YELLOW}⏭️ Criação cancelada${NC}"
fi