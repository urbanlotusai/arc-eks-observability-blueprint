# Sample App

A **zero-dependency Node.js HTTP service** that emits structured JSON logs on every request, proving the EFK + Prometheus/Grafana observability stack captures and displays real application telemetry.

```
Pod stdout → Fluent Bit (DaemonSet) → OpenSearch + S3 archive
Pod metrics → Prometheus → Grafana dashboards
```

This blueprint has no ECR module — push the image to any registry you control (Docker Hub, GHCR, or an ECR repo from another ARC blueprint).

---

## What it does

`GET /` → JSON welcome payload **and** logs a structured JSON line to stdout (`{"level":"info","message":"request handled",...}`).
`GET /health` → `{ "status": "ok" }`.

## Test locally

```bash
cd sample-app
node index.js          # starts on :8080
curl http://localhost:8080/
```

## Build and push

```bash
IMAGE=<your-registry>/arc-eks-observability-sample:latest
docker build -t $IMAGE sample-app/
docker push $IMAGE
```

## Deploy to EKS

```bash
$(terraform output -raw kubeconfig_command)

sed -i "s|REPLACE_WITH_ECR_URL:latest|$IMAGE|g" sample-app/k8s/deployment.yaml
kubectl apply -f sample-app/k8s/namespace.yaml
kubectl apply -f sample-app/k8s/deployment.yaml
kubectl apply -f sample-app/k8s/service.yaml
```

## Verify the observability stack sees it

```bash
# Generate some traffic
kubectl run -n sample-tenant curl-test --rm -it --image=curlimages/curl --restart=Never -- curl http://sample-app

# Check logs landed in OpenSearch (via Grafana/Kibana port-forward, see docs/DEPLOYMENT.md)
# Check Prometheus is scraping the pod's /metrics or default kubelet cAdvisor metrics
```

## Order of operations

1. `terraform apply` — creates cluster, EFK/Prometheus/Grafana stack, S3 log archive
2. Build + push image to any registry
3. Update kubeconfig
4. `kubectl apply` the k8s manifests
5. Generate traffic and confirm logs/metrics appear in the dashboards

---

Built by **[SourceFuse](https://www.sourcefuse.com)**.
