# =============================================================================
# 07-observability - HIPAA Compliance Profile
# =============================================================================
# HIPAA does not mandate a specific log aggregation/metrics stack. The
# module's variable interface has no compliance-specific knobs, so values
# are kept identical to the general profile.
# =============================================================================

search_engine             = "opensearch"
log_aggregator            = "fluent-bit"
metrics_monitoring_system = "prometheus"
