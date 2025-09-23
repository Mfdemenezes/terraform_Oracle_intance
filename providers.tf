# =============================================================================
# TERRAFORM ORACLE CLOUD INFRASTRUCTURE - PROVIDERS
# =============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Provider Oracle Cloud Infrastructure
provider "oci" {
  region              = var.region
  tenancy_ocid        = var.tenancy_ocid
  user_ocid           = data.oci_identity_user.current_user.id
  fingerprint         = data.oci_identity_api_key.current_key.fingerprint
  private_key_path    = "~/.ssh/oracle/api_key.pem"
}

# Data sources para informações atuais
data "oci_identity_user" "current_user" {
  user_id = var.tenancy_ocid
}

data "oci_identity_api_key" "current_key" {
  user_id = data.oci_identity_user.current_user.id
}

# Locals para valores computados
locals {
  compartment_id = var.compartment_ocid != "" ? var.compartment_ocid : var.tenancy_ocid

  common_tags = merge(var.tags, {
    "Terraform"   = "true"
    "CreatedDate" = timestamp()
  })

  instance_names = [
    for i in range(var.instance_count) :
    "${var.project_name}-${var.environment}-${i + 1}"
  ]
}