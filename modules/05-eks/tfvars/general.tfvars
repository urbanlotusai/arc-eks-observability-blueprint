# =============================================================================
# 05-eks - General Compliance Profile
# =============================================================================
# Node sizing is a capacity/cost choice, not a compliance requirement — the
# module's variable interface has no compliance-specific knobs (secrets are
# always KMS-encrypted via cluster_encryption_config in main.tf regardless
# of profile). See hipaa.tfvars / pci.tfvars for why sizing stays the same.
# =============================================================================

kubernetes_version  = "1.29"
node_instance_types = ["m5.xlarge"]
node_desired_size   = 3
node_min_size       = 2
node_max_size       = 6
