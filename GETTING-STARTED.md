# Getting Started

See **[docs/INSTALL.md](docs/INSTALL.md)** to install Terraform, kubectl, and the AWS CLI.

After deploying, update your kubeconfig:
```bash
$(terraform output -raw kubeconfig_command)
kubectl get nodes
kubectl get pods -n logging    # Fluent Bit / Fluentd pods
kubectl get pods -n monitoring # Prometheus + Grafana pods
```

Access Grafana:
```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
# Open http://localhost:3000 (default admin/prom-operator)
```
