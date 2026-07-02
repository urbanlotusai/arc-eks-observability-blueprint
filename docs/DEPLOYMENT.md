# Deployment Reference

## Deploy

```bash
cp examples/general.tfvars terraform.tfvars
terraform init && terraform plan && terraform apply
```

> EKS cluster creation takes ~15 minutes. The observability stack Helm charts deploy after.

## Post-apply

```bash
# Update kubeconfig
$(terraform output -raw kubeconfig_command)

# Check all observability pods are running
kubectl get pods --all-namespaces | grep -E "logging|monitoring"

# Port-forward Grafana
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

## Tear down

```bash
# Remove Helm releases first to avoid stuck finalizers
helm uninstall -n monitoring prometheus
helm uninstall -n logging fluent-bit
helm uninstall -n logging opensearch

terraform destroy
```
