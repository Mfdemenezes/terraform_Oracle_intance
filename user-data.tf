# =============================================================================
# TERRAFORM ORACLE CLOUD INFRASTRUCTURE - USER DATA
# =============================================================================

# Template do User Data Script
locals {
  user_data_script = var.install_dev_tools ? base64encode(templatefile("${path.module}/user-data.sh", {
    docker_compose_version = var.docker_compose_version
    project_name           = var.project_name
    environment           = var.environment
  })) : null
}

# Script de User Data para instalação automática das ferramentas
resource "local_file" "user_data_script" {
  count = var.install_dev_tools ? 1 : 0

  filename = "${path.module}/user-data.sh"
  content  = templatefile("${path.module}/user-data.tpl", {
    docker_compose_version = var.docker_compose_version
    project_name           = var.project_name
    environment           = var.environment
  })

  depends_on = [local_file.user_data_template]
}

# Template do script user-data
resource "local_file" "user_data_template" {
  filename = "${path.module}/user-data.tpl"
  content  = <<-EOF
#!/bin/bash

# ${project_name} ${environment} Instance - User Data Essencial
# Log: /var/log/user-data.log

exec > /var/log/user-data.log 2>&1

echo "=========================================="
echo "Iniciando setup ${project_name} ${environment} - $(date)"
echo "Docker Compose Version: ${docker_compose_version}"
echo "=========================================="

# Atualizar sistema
export DEBIAN_FRONTEND=noninteractive
apt-get update -y

# Instalar ferramentas essenciais
apt-get install -y git docker.io curl htop tree unzip vim

# Configurar Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Instalar Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v$${docker_compose_version}/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Criar link simbólico para compatibilidade
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Configurar timezone
timedatectl set-timezone America/Sao_Paulo

# Criar script de verificação
cat > /home/ubuntu/check-tools.sh << 'EOL'
#!/bin/bash
echo "=========================================="
echo "VERIFICAÇÃO DAS FERRAMENTAS - ${project_name}"
echo "=========================================="
echo "Data: $(date)"
echo "Instância: $(hostname)"
echo ""
echo "Git: $(git --version)"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo "Sistema: $(lsb_release -d | cut -f2)"
echo ""
echo "Status Docker: $(systemctl is-active docker)"
echo "Grupo Docker: $(groups ubuntu | grep docker && echo 'OK' || echo 'NOT CONFIGURED')"
echo "=========================================="
EOL

chmod +x /home/ubuntu/check-tools.sh
chown ubuntu:ubuntu /home/ubuntu/check-tools.sh

# Verificar instalações
echo "=== VERIFICAÇÃO FINAL ===" >> /var/log/user-data.log
git --version >> /var/log/user-data.log 2>&1
docker --version >> /var/log/user-data.log 2>&1
docker-compose --version >> /var/log/user-data.log 2>&1

echo "=========================================="
echo "Setup ${project_name} ${environment} concluído - $(date)"
echo "Log completo: /var/log/user-data.log"
echo "Verificação: /home/ubuntu/check-tools.sh"
echo "=========================================="
EOF
}