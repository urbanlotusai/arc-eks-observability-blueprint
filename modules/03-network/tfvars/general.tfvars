# =============================================================================
# 03-network - General Compliance Profile
# =============================================================================
# No compliance controls are profile-specific for this module — the VPC
# CIDR is a sizing/addressing choice, not a compliance requirement. See
# hipaa.tfvars / pci.tfvars for why the value stays the same across profiles.
# =============================================================================

vpc_cidr = "10.0.0.0/16"
