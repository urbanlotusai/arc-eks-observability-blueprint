# =============================================================================
# 05-eks - HIPAA Compliance Profile
# =============================================================================
# HIPAA does not mandate specific node counts or instance types. Cluster
# secrets are already encrypted with the CMK from 01-kms unconditionally in
# main.tf, so there is no additional compliance-driven override here — sizing
# is kept identical to the general profile.
# =============================================================================

kubernetes_version  = "1.29"
node_instance_types = ["m5.xlarge"]
node_desired_size   = 3
node_min_size       = 2
node_max_size       = 6
