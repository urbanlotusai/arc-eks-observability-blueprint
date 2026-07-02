locals {
  # ── Naming ────────────────────────────────────────────────────────────────────
  name_prefix    = "${var.namespace}-${var.environment}"
  kms_alias      = "alias/${local.name_prefix}-eks-obs"
  log_bucket     = "${local.name_prefix}-observability-logs"
  cluster_name   = "${local.name_prefix}-eks"

  # ── Compliance overlay ────────────────────────────────────────────────────────
  is_hipaa           = var.compliance_profile == "hipaa"
  is_pci_dss         = var.compliance_profile == "pci_dss"
  is_strict          = local.is_hipaa || local.is_pci_dss
  log_retention_days = local.is_strict ? 365 : var.log_retention_days

  # ── Tagging ───────────────────────────────────────────────────────────────────
  tags = {
    Environment       = var.environment
    Namespace         = var.namespace
    ManagedBy         = "terraform"
    Application       = "eks-observability"
    ComplianceProfile = var.compliance_profile
  }
}
