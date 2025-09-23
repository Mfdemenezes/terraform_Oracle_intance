# =============================================================================
# TERRAFORM ORACLE CLOUD INFRASTRUCTURE - OUTPUTS
# =============================================================================

# Informações das instâncias
output "instances" {
  description = "Informações detalhadas das instâncias criadas"
  value = {
    for i, instance in oci_core_instance.dev_instances : local.instance_names[i] => {
      id               = instance.id
      name             = instance.display_name
      state            = instance.state
      availability_domain = instance.availability_domain
      fault_domain     = instance.fault_domain
      shape            = instance.shape
      private_ip       = instance.private_ip
      public_ip        = var.create_reserved_ip ? oci_core_public_ip.instance_ips[i].ip_address : instance.public_ip
      ssh_command      = "ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@${var.create_reserved_ip ? oci_core_public_ip.instance_ips[i].ip_address : instance.public_ip}"
      reserved_ip      = var.create_reserved_ip ? oci_core_public_ip.instance_ips[i].ip_address : null
      reserved_ip_id   = var.create_reserved_ip ? oci_core_public_ip.instance_ips[i].id : null
    }
  }
}

# Lista de IPs públicos
output "public_ips" {
  description = "Lista dos IPs públicos das instâncias"
  value = [
    for i in range(var.instance_count) :
    var.create_reserved_ip ? oci_core_public_ip.instance_ips[i].ip_address : oci_core_instance.dev_instances[i].public_ip
  ]
}

# Lista de IPs privados
output "private_ips" {
  description = "Lista dos IPs privados das instâncias"
  value = [
    for instance in oci_core_instance.dev_instances :
    instance.private_ip
  ]
}

# Comandos SSH para todas as instâncias
output "ssh_commands" {
  description = "Comandos SSH para conectar nas instâncias"
  value = [
    for i in range(var.instance_count) :
    "ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@${var.create_reserved_ip ? oci_core_public_ip.instance_ips[i].ip_address : oci_core_instance.dev_instances[i].public_ip}"
  ]
}

# Informações dos IPs reservados
output "reserved_ips" {
  description = "Informações dos IPs públicos reservados"
  value = var.create_reserved_ip ? {
    for i, ip in oci_core_public_ip.instance_ips : local.instance_names[i] => {
      id         = ip.id
      ip_address = ip.ip_address
      lifetime   = ip.lifetime
      scope      = ip.scope
      state      = ip.state
    }
  } : {}
}

# Resumo da infraestrutura
output "infrastructure_summary" {
  description = "Resumo da infraestrutura criada"
  value = {
    project_name        = var.project_name
    environment        = var.environment
    region             = var.region
    availability_domain = var.availability_domain
    instance_count     = var.instance_count
    instance_shape     = var.instance_shape
    reserved_ips       = var.create_reserved_ip
    dev_tools_installed = var.install_dev_tools
    docker_compose_version = var.docker_compose_version
    created_at         = timestamp()
  }
}

# Informações de conexão
output "connection_info" {
  description = "Informações para conectar nas instâncias"
  value = {
    ssh_key_path    = var.ssh_public_key_path
    username        = "ubuntu"
    operating_system = "Ubuntu 22.04 LTS"
    tools_installed = var.install_dev_tools ? ["git", "docker", "docker-compose"] : []
    user_data_log   = "/var/log/user-data.log"
    check_script    = "/home/ubuntu/check-tools.sh"
  }
}

# URLs e comandos úteis
output "useful_commands" {
  description = "Comandos úteis para gerenciar as instâncias"
  value = {
    # Verificar status das ferramentas
    check_tools = [
      for i in range(var.instance_count) :
      "ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@${var.create_reserved_ip ? oci_core_public_ip.instance_ips[i].ip_address : oci_core_instance.dev_instances[i].public_ip} './check-tools.sh'"
    ]

    # Ver logs de user-data
    view_logs = [
      for i in range(var.instance_count) :
      "ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@${var.create_reserved_ip ? oci_core_public_ip.instance_ips[i].ip_address : oci_core_instance.dev_instances[i].public_ip} 'sudo cat /var/log/user-data.log'"
    ]

    # Testar Docker
    test_docker = [
      for i in range(var.instance_count) :
      "ssh -i ~/.ssh/oracle/ssh-key-2025-09-15.key ubuntu@${var.create_reserved_ip ? oci_core_public_ip.instance_ips[i].ip_address : oci_core_instance.dev_instances[i].public_ip} 'docker run hello-world'"
    ]
  }
}

# Custos estimados (informativo)
output "cost_information" {
  description = "Informações sobre custos (estimativa)"
  value = {
    instance_type    = "Free Tier (VM.Standard.E2.1.Micro)"
    instance_cost    = "Gratuito até 3000 OCPU horas/mês"
    reserved_ip_cost = var.create_reserved_ip ? "Taxa nominal por IP reservado" : "Sem custo (IP efêmero)"
    bandwidth_cost   = "10TB gratuitos por mês"
    storage_cost     = "Boot volume incluído no Free Tier"
    note            = "Monitore custos no Oracle Cloud Console"
  }
}

# Informações do bucket de state
output "bucket_info" {
  description = "Informações do bucket para armazenar Terraform state"
  value = {
    bucket_name       = oci_objectstorage_bucket.terraform_state.name
    namespace         = data.oci_objectstorage_namespace.current.namespace
    bucket_url        = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.current.namespace}/b/${oci_objectstorage_bucket.terraform_state.name}"
    s3_endpoint       = "https://${data.oci_objectstorage_namespace.current.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
    backend_config    = "bucket = \"${oci_objectstorage_bucket.terraform_state.name}\""
    setup_instructions = [
      "1. Configure Customer Secret Keys no Oracle Cloud Console",
      "2. Adicione AWS_ACCESS_KEY_ID e AWS_SECRET_ACCESS_KEY nos GitHub Secrets",
      "3. Descomente configuração backend em backend.tf",
      "4. Execute: terraform init -migrate-state"
    ]
  }
}