# =============================================================================
# TERRAFORM ORACLE CLOUD INFRASTRUCTURE - RECURSOS PRINCIPAIS
# =============================================================================

# Data sources para VPC e Subnet existentes
data "oci_core_vcn" "existing_vcn" {
  count  = var.use_existing_vpc ? 1 : 0
  vcn_id = var.existing_vcn_ocid
}

data "oci_core_subnet" "existing_subnet" {
  count     = var.use_existing_vpc ? 1 : 0
  subnet_id = var.existing_subnet_ocid
}

# Data source para availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = local.compartment_id
}

# Data source para chave SSH pública
data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

# Criar IPs públicos reservados (se solicitado)
resource "oci_core_public_ip" "reserved_ips" {
  count          = var.create_reserved_ip ? var.instance_count : 0
  compartment_id = local.compartment_id
  lifetime       = "RESERVED"
  display_name   = "${local.instance_names[count.index]}-reserved-ip"

  freeform_tags = local.common_tags
}

# Criar instâncias compute
resource "oci_core_instance" "dev_instances" {
  count               = var.instance_count
  compartment_id      = local.compartment_id
  availability_domain = var.availability_domain
  display_name        = local.instance_names[count.index]
  shape               = var.instance_shape

  # Configurações da instância
  shape_config {
    ocpus         = 1
    memory_in_gbs = 1
  }

  # Imagem do sistema operacional
  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid
  }

  # Configurações de rede
  create_vnic_details {
    subnet_id                 = var.use_existing_vpc ? var.existing_subnet_ocid : oci_core_subnet.dev_subnet[0].id
    assign_public_ip          = var.create_reserved_ip ? false : true
    assign_private_dns_record = true
    display_name              = "${local.instance_names[count.index]}-vnic"
    hostname_label            = replace(local.instance_names[count.index], "-", "")
  }

  # Configurações SSH e User Data
  metadata = {
    ssh_authorized_keys = data.local_file.ssh_public_key.content
    user_data          = local.user_data_script
  }

  # Configurações da instância
  instance_options {
    are_legacy_imds_endpoints_disabled = false
  }

  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }

  freeform_tags = merge(local.common_tags, {
    "Name" = local.instance_names[count.index]
    "Type" = "compute-instance"
  })

  # Aguardar criação completa
  timeouts {
    create = "10m"
  }
}

# Anexar IPs reservados às instâncias (se criados)
resource "oci_core_public_ip" "instance_ips" {
  count        = var.create_reserved_ip ? var.instance_count : 0
  compartment_id = local.compartment_id
  lifetime     = "RESERVED"
  display_name = "${local.instance_names[count.index]}-ip"

  # Anexar ao private IP da instância
  private_ip_id = data.oci_core_private_ips.instance_private_ips[count.index].private_ips[0].id

  freeform_tags = local.common_tags

  depends_on = [oci_core_instance.dev_instances]
}

# Data source para obter private IPs das instâncias
data "oci_core_private_ips" "instance_private_ips" {
  count   = var.create_reserved_ip ? var.instance_count : 0
  vnic_id = oci_core_instance.dev_instances[count.index].primary_vnic_id

  depends_on = [oci_core_instance.dev_instances]
}

# Aguardar instâncias ficarem disponíveis
resource "null_resource" "wait_for_instances" {
  count = var.instance_count

  provisioner "local-exec" {
    command = "sleep 60"
  }

  depends_on = [oci_core_instance.dev_instances]
}

# Verificar conectividade SSH
resource "null_resource" "test_ssh_connectivity" {
  count = var.instance_count

  provisioner "local-exec" {
    command = <<-EOT
      echo "Testando conectividade SSH para ${local.instance_names[count.index]}..."
      for i in {1..10}; do
        if ssh -i ${pathexpand("~/.ssh/oracle/ssh-key-2025-09-15.key")} -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@${var.create_reserved_ip ? oci_core_public_ip.instance_ips[count.index].ip_address : oci_core_instance.dev_instances[count.index].public_ip} "echo 'SSH OK'"; then
          echo "SSH conectado com sucesso para ${local.instance_names[count.index]}"
          break
        else
          echo "Tentativa $i/10 falhou, aguardando 30s..."
          sleep 30
        fi
      done
    EOT
  }

  depends_on = [
    oci_core_instance.dev_instances,
    oci_core_public_ip.instance_ips,
    null_resource.wait_for_instances
  ]
}