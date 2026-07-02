# =============================================================================
# 07-observability - General Compliance Profile
# =============================================================================
# No compliance controls are profile-specific for this module — search
# engine / log aggregator / metrics stack are architectural choices, not
# compliance requirements. See hipaa.tfvars / pci.tfvars for why the values
# stay the same across all profiles.
# =============================================================================

search_engine             = "opensearch"
log_aggregator            = "fluent-bit"
metrics_monitoring_system = "prometheus"
