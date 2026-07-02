# =============================================================================
# 03-network - PCI Compliance Profile
# =============================================================================
# PCI DSS network-segmentation requirements (Req 1) are satisfied by the
# module's public/private subnet split, not by a specific CIDR value. The
# default addressing is kept the same as the general profile.
# =============================================================================

vpc_cidr = "10.0.0.0/16"
