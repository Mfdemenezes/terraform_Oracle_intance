# Oracle Cloud Infrastructure - Terraform Automation

Infraestrutura automatizada para Oracle Cloud usando Terraform com instâncias Ubuntu, Docker e ferramentas de desenvolvimento.

## 🚀 Recursos

- **Instâncias Ubuntu 22.04 LTS** com ferramentas pré-instaladas
- **IPs reservados** para persistência entre reinicializações
- **Docker e Docker Compose** instalados automaticamente
- **User-data script** otimizado para configuração rápida
- **Múltiplas instâncias** configuráveis
- **Free Tier** compatível (VM.Standard.E2.1.Micro)

## 📋 Pré-requisitos

1. **Oracle Cloud Account** com Free Tier ativo
2. **Terraform** instalado (>= 1.0)
3. **Oracle CLI** configurado
4. **Chave SSH** para as instâncias

### Configuração Oracle CLI

```bash
# Configure as credenciais
oci setup config

# Gere chave API se necessário
mkdir -p ~/.ssh/oracle
openssl genrsa -out ~/.ssh/oracle/api_key.pem 2048
openssl rsa -pubout -in ~/.ssh/oracle/api_key.pem -out ~/.ssh/oracle/api_key_public.pem
```

### Chave SSH para Instâncias

```bash
# Crie chave SSH se não existir
ssh-keygen -t rsa -b 2048 -f ~/.ssh/oracle/ssh-key-2025-09-15.key
```

## 🛠️ Configuração

1. **Clone e configure o projeto:**
```bash
git clone <seu-repositorio>
cd terraform-oracle-cloud-dev
```

2. **Edite o arquivo `terraform.tfvars`:**
```hcl
# Configurações do Projeto
project_name = "seu-projeto"
environment  = "dev"

# Oracle Cloud - OBRIGATÓRIO: Atualize com seus valores
tenancy_ocid    = "ocid1.tenancy.oc1..aaaa..."
compartment_ocid = "ocid1.compartment.oc1..aaaa..."
instance_image_ocid = "ocid1.image.oc1.sa-saopaulo-1.aaaa..."

# VPC Existente - OBRIGATÓRIO: Atualize com seus valores
existing_vcn_ocid    = "ocid1.vcn.oc1.sa-saopaulo-1.aaaa..."
existing_subnet_ocid = "ocid1.subnet.oc1.sa-saopaulo-1.aaaa..."

# SSH Key - OBRIGATÓRIO: Verifique o caminho
ssh_public_key_path = "~/.ssh/oracle/ssh-key-2025-09-15.key.pub"

# Configurações das Instâncias
instance_count     = 2
create_reserved_ip = true
install_dev_tools  = true
```

3. **Obtenha os OCIDs necessários:**
```bash
# Listar compartments
oci iam compartment list

# Listar VCNs
oci network vcn list --compartment-id <compartment-ocid>

# Listar subnets
oci network subnet list --compartment-id <compartment-ocid>

# Listar imagens Ubuntu
oci compute image list --compartment-id <compartment-ocid> --operating-system "Canonical Ubuntu"
```

## 🚀 Deploy

### Opção 1: Deploy Local
```bash
# Inicializar Terraform
terraform init

# Planejar deployment
terraform plan

# Aplicar infraestrutura
terraform apply
```

### Opção 2: Deploy com Backend Remoto
```bash
# 1. Configurar bucket de state primeiro
./setup-state-bucket.sh

# 2. Seguir instruções para configurar backend
# 3. Migrar state: terraform init -migrate-state

# 4. Deploy normal
terraform apply
```

### Opção 3: GitHub Actions
- **Push para main**: Deploy automático
- **Pull Request**: Plan automático com comentário
- **Manual Destroy**: Actions > Oracle Cloud Infrastructure > Run workflow > destroy

## 📊 Outputs

Após o deploy, você terá acesso a:

```bash
# Ver todos os outputs
terraform output

# SSH commands prontos
terraform output ssh_commands

# IPs públicos
terraform output public_ips

# Informações detalhadas
terraform output instances
```

## 🔧 Comandos Úteis

### Conexão SSH
```bash
# Usar output do Terraform
terraform output -raw ssh_commands

# Ou conectar diretamente
ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@<ip-publico>
```

### Verificar Instalações
```bash
# Verificar ferramentas instaladas
ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@<ip> './check-tools.sh'

# Ver logs de instalação
ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@<ip> 'sudo cat /var/log/user-data.log'
```

### Gerenciamento
```bash
# Destruir infraestrutura
terraform destroy

# Atualizar apenas user-data
terraform apply -target=local_file.user_data_script

# Ver estado atual
terraform show
```

## 🛡️ Troubleshooting

### SSH Host Key Issues
```bash
# Remover chave antiga se IP foi reutilizado
ssh-keygen -R <ip-publico>
```

### User-Data não executou
```bash
# Verificar logs
ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@<ip> 'sudo tail -f /var/log/user-data.log'

# Reexecutar user-data manualmente
ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@<ip> 'sudo /var/lib/cloud/instance/scripts/part-001'
```

### Docker não funcionando
```bash
# Verificar status
ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@<ip> 'sudo systemctl status docker'

# Reiniciar Docker
ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@<ip> 'sudo systemctl restart docker'

# Testar Docker
ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@<ip> 'docker run hello-world'
```

## 💰 Custos

- **Instâncias**: Free Tier (até 3000 OCPU horas/mês)
- **IPs Reservados**: Taxa nominal (~$0.004/hora)
- **Bandwidth**: 10TB gratuitos/mês
- **Storage**: Boot volume incluído no Free Tier

**💡 Dica**: Monitor custos no Oracle Cloud Console

## 📁 Estrutura do Projeto

```
terraform-oracle-cloud-dev/
├── main.tf              # Recursos principais
├── variables.tf         # Variáveis configuráveis
├── providers.tf         # Configuração providers
├── outputs.tf          # Outputs informativos
├── user-data.tf        # Scripts de inicialização
├── terraform.tfvars    # Valores das variáveis
└── README.md           # Esta documentação
```

## 🔄 Customização

### Alterar número de instâncias
```hcl
# terraform.tfvars
instance_count = 3
```

### Desabilitar IPs reservados
```hcl
# terraform.tfvars
create_reserved_ip = false
```

### Usar imagem diferente
```hcl
# terraform.tfvars
instance_image_ocid = "ocid1.image.oc1.sa-saopaulo-1.sua-imagem"
```

### Personalizar user-data
Edite o template em `user-data.tf` para adicionar/remover ferramentas.

## 📝 Notas Importantes

1. **Primeiro deploy**: Pode levar 3-5 minutos para user-data completar
2. **SSH**: Use a chave específica gerada para as instâncias
3. **IPs reservados**: Persistem mesmo quando instância é terminada
4. **Free Tier**: Monitore limites para evitar cobranças
5. **Região**: Configurado para São Paulo (sa-saopaulo-1)

---

**Criado com Terraform para Oracle Cloud Infrastructure**