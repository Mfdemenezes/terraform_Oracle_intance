# =============================================================================
# TERRAFORM STATE BUCKET - ORACLE OBJECT STORAGE
# =============================================================================

# Bucket para armazenar o Terraform State no Oracle Object Storage
resource "oci_objectstorage_bucket" "terraform_state" {
  compartment_id = local.compartment_id
  name           = "${var.project_name}-${var.environment}-terraform-state"
  namespace      = data.oci_objectstorage_namespace.current.namespace

  # Configurações de segurança
  access_type                = "NoPublicAccess"
  storage_tier               = "Standard"
  object_events_enabled      = false
  versioning                 = "Enabled"

  # Configurações de retenção
  retention_rules {
    display_name = "terraform-state-retention"

    duration {
      time_amount = 30
      time_unit   = "DAYS"
    }

    time_rule_locked = "2025-12-31T23:59:59Z"
  }

  freeform_tags = merge(local.common_tags, {
    "Purpose" = "terraform-state"
    "Type"    = "object-storage"
  })
}

# Data source para namespace
data "oci_objectstorage_namespace" "current" {
  compartment_id = local.compartment_id
}

# Pré-autenticação para acesso via GitHub Actions
resource "oci_objectstorage_preauthrequest" "terraform_state_access" {
  namespace    = data.oci_objectstorage_namespace.current.namespace
  bucket       = oci_objectstorage_bucket.terraform_state.name
  name         = "${var.project_name}-terraform-state-access"
  access_type  = "AnyObjectReadWrite"
  time_expires = "2025-12-31T23:59:59Z"

  depends_on = [oci_objectstorage_bucket.terraform_state]
}