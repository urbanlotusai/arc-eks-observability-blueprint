<div align="center">

# ARC EKS with Full Observability Blueprint

### Production EKS cluster with built-in logging, metrics, and dashboards — one `terraform apply`

**A SourceFuse ARC Blueprint**

![Version](https://img.shields.io/badge/version-1.0.0-E8392A)
![License](https://img.shields.io/badge/license-Apache--2.0-1A1A2E)
![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.3-7B42BC)
![AWS Provider](https://img.shields.io/badge/aws--provider-%3E%3D5.0-FF9900)
![ARC Modules](https://img.shields.io/badge/ARC%20modules-7-E8392A)

</div>

---

## What is this?

A **ready-to-deploy Terraform blueprint** that provisions a production EKS cluster and wires a
full observability stack onto it — using **7 [SourceFuse ARC](https://registry.terraform.io/namespaces/modules/sourcefuse)
modules**. One `terraform apply` delivers:

- **EKS cluster** with managed node groups and encrypted secrets (KMS CMK)
- **AWS EKS addons**: VPC CNI, CoreDNS, kube-proxy, EBS CSI Driver
- **OpenSearch** (in-cluster) for log aggregation
- **Fluent Bit** for container log shipping → OpenSearch + S3 archive
- **Prometheus + Alertmanager** for metrics collection and alerting
- **Grafana** dashboards wired to Prometheus

No hand-wiring of Helm releases, IAM roles for service accounts, or log routing. The hard parts are already solved and pinned.

---

## Why use this blueprint?

| Advantage | What it means for you |
|---|---|
| **Minutes, not days** | EKS + full EFK + Prometheus + Grafana normally requires days of Helm wiring. This deploys in one command. |
| **Secure by default** | KMS CMK encrypts EKS secrets and the S3 log archive. Fluent Bit ships logs over mTLS. |
| **Observable on day one** | Grafana dashboards and Prometheus alerts are live immediately after apply — not "left as an exercise." |
| **Long-term retention** | Fluent Bit fans out to both OpenSearch (hot) and KMS-encrypted S3 (cold). Logs survive cluster deletion. |
| **Proven building blocks** | Every resource comes from a published, versioned SourceFuse ARC module. Upgrades are a version bump. |
| **Portable & auditable** | Pure Terraform. Version-controlled, reproducible across environments and accounts. |

---

## Architecture

```
  EKS Cluster (managed node groups)
       │
       ├── Fluent Bit (DaemonSet)
       │        ├──► OpenSearch (log aggregation — hot storage)
       │        └──► S3 Archive (KMS-encrypted — cold storage)
       │
       ├── Prometheus + Alertmanager (metrics)
       │        └──► Grafana (dashboards + alert routing)
       │
       └── KMS CMK ── EKS secrets · S3 log archive
```

---

## The 7 ARC modules

| Module | Version | Role |
|---|---|---|
| [arc-kms](https://registry.terraform.io/modules/sourcefuse/arc-kms/aws) | 1.0.11 | CMK for EKS secrets + S3 archive |
| [arc-s3](https://registry.terraform.io/modules/sourcefuse/arc-s3/aws) | 0.0.7 | Long-term log archive (encrypted, private) |
| [arc-network](https://registry.terraform.io/modules/sourcefuse/arc-network/aws) | 3.0.14 | VPC + public/private subnets |
| [arc-security-group](https://registry.terraform.io/modules/sourcefuse/arc-security-group/aws) | 0.0.5 | Cluster and node security group |
| [arc-eks](https://registry.terraform.io/modules/sourcefuse/arc-eks/aws) | 6.0.4 | EKS cluster + managed node groups |
| [arc-eks-addon](https://registry.terraform.io/modules/sourcefuse/arc-eks-addon/aws) | 1.0.3 | VPC CNI, CoreDNS, kube-proxy, EBS CSI |
| [arc-observability-stack](https://registry.terraform.io/modules/sourcefuse/arc-observability-stack/aws) | 1.0.2 | EFK (Fluent Bit + OpenSearch) + Prometheus + Grafana |

---

## Quick start

### 1. Prerequisites

- **Terraform** `>= 1.3` ([install guide](docs/INSTALL.md))
- **AWS credentials** configured (`aws configure`)
- **kubectl** installed ([install guide](https://kubernetes.io/docs/tasks/tools/))

### 2. Configure

```bash
git clone https://github.com/sourcefuse/arc-eks-observability-blueprint.git
cd arc-eks-observability-blueprint

cp examples/general.tfvars terraform.tfvars
```

Edit the mandatory values in `terraform.tfvars`:

| Variable | Example |
|---|---|
| `environment` | `prod` |
| `namespace` | `myorg` |

### 3. Deploy

| Step | With `make` | Raw Terraform (all OS) |
|---|---|---|
| Validate | `make validate` | `terraform init -backend=false && terraform validate` |
| Preview | `make plan` | `terraform plan` |
| Deploy | `make apply` | `terraform init && terraform apply` |

### 4. Access dashboards

```bash
# Update local kubeconfig
$(terraform output -raw kubeconfig_command)

# Verify observability pods are running
kubectl get pods --all-namespaces | grep -E 'observability|prometheus|grafana|fluent'

# Port-forward Grafana
kubectl port-forward svc/grafana 3000:3000 -n observability
# Open http://localhost:3000 (admin / admin)
```

---

## Compliance profiles

| Profile | Effect |
|---|---|
| `general` | KMS rotation on, 90-day S3 log retention |
| `hipaa` | 365-day S3 log retention, EKS secrets encrypted with CMK (enforced) |
| `pci_dss` | 365-day S3 log retention, EKS secrets encrypted with CMK (enforced) |

---

## Key outputs

```bash
terraform output cluster_id             # EKS cluster name
terraform output cluster_endpoint       # EKS API server endpoint
terraform output kubeconfig_command     # aws eks update-kubeconfig ...
terraform output s3_log_archive_bucket  # S3 bucket for long-term logs
terraform output kms_key_arn            # CMK
terraform output vpc_id                 # VPC ID
```

---

## Project structure

```
arc-eks-observability-blueprint/
├── main.tf                   # 7 ARC module blocks, in dependency order
├── variables.tf              # all inputs with types & descriptions
├── locals.tf                 # naming, tags, compliance overlays
├── data.tf                   # caller identity, KMS policy, subnet lookups, EKS auth
├── outputs.tf                # cluster ID, endpoint, kubeconfig command, S3, KMS
├── version.tf                # Terraform + AWS + kubernetes + helm provider pins
├── terraform.tfvars.example  # copy to terraform.tfvars
├── examples/
│   ├── README.md
│   ├── general.tfvars
│   ├── hipaa.tfvars
│   └── pci_dss.tfvars
├── docs/
│   ├── INSTALL.md            # macOS · Linux · Windows setup guide
│   └── DEPLOYMENT.md        # full deployment + dashboard access + rollback
├── GETTING-STARTED.md        # beginner walkthrough
├── CONTRIBUTING.md
├── CHANGELOG.md · LICENSE · NOTICE · Makefile · VERSION
└── README.md
```

---

## Documentation

- **[GETTING-STARTED.md](GETTING-STARTED.md)** — zero-to-live walkthrough for first-timers
- **[docs/INSTALL.md](docs/INSTALL.md)** — install Terraform, AWS CLI, and kubectl on macOS / Linux / Windows
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** — full deployment guide, dashboard access, log queries, rollback
- **[examples/README.md](examples/README.md)** — compliance-profile example files

---

## Important notes

- **Two providers need EKS to exist before configuring** — the `kubernetes` and `helm` providers in `version.tf` reference `module.eks` outputs. If running `terraform plan` before `apply`, the providers will show a configuration error; this resolves after the first apply populates the cluster endpoint.
- **EKS addons must complete before observability-stack** — `module.observability_stack` has `depends_on = [module.eks_addons]` to ensure VPC CNI and EBS CSI are ready before Helm charts deploy.
- **Grafana default credentials** — change the admin password immediately after first login.
- **S3 log bucket** — Fluent Bit ships to S3 in addition to OpenSearch. This is the cold-storage tier for logs older than the OpenSearch retention window.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Apache License 2.0 — see [LICENSE](LICENSE) and [NOTICE](NOTICE).

---

<div align="center">

### Built by [SourceFuse](https://www.sourcefuse.com)

Part of the **ARC** (Accelerated Reference Cloud) blueprint family.
Explore all ARC modules on the [Terraform Registry](https://registry.terraform.io/namespaces/modules/sourcefuse).

</div>
