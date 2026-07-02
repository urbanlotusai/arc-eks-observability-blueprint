# ── Profile: hipaa ────────────────────────────────────────────────────────────
# Activates the HIPAA overlay:
#   - S3 log archive retention extended to 365 days
#   - EKS secrets encryption with CMK enforced

environment = "prod"
namespace   = "myorg"

compliance_profile = "hipaa"

# Cluster sizing for HIPAA workloads
node_instance_types = ["m5.large"]
node_desired_size   = 3
node_min_size       = 3
node_max_size       = 10
