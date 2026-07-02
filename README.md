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

### 2. Clone

```bash
git clone https://github.com/urbanlotusai/arc-eks-observability-blueprint.git
cd arc-eks-observability-blueprint
```

This blueprint uses **independent per-module Terraform state** — there is no root `main.tf`. Each `modules/NN-name/` is applied on its own, with cross-module values (like the KMS key ARN, VPC ID, or cluster ID) resolved via `terraform_remote_state` data sources rather than a parent module.

### 3. Bootstrap the state backend (once per environment)

```bash
make bootstrap ENV=dev REGION=us-east-1 NAMESPACE=myorg
```

Creates the S3 state bucket + DynamoDB lock table every module's backend uses.

### 4. Deploy all modules

```bash
make apply ENV=dev REGION=us-east-1 NAMESPACE=myorg
```

This runs `terraform init` + `apply` across `modules/01-kms` through `modules/07-observability` in order.

### Deploy a single module with a compliance profile

```bash
./scripts/apply-module.sh 05-eks dev us-east-1 hipaa
```

Copies `modules/05-eks/tfvars/hipaa.tfvars` → `terraform.tfvars` for that module, then inits/plans/applies it alone.

| Step | With `make` (all modules) | Single module |
|---|---|---|
| Validate | `make validate` | `cd modules/<NN-name> && terraform validate` |
| Preview | `make plan` | `./scripts/apply-module.sh <name> <env> <region> <profile>` then inspect the plan |
| Deploy | `make apply` | `./scripts/apply-module.sh <name> <env> <region> <profile>` |

### 5. Access dashboards

```bash
# Update local kubeconfig (cluster_id comes from the 05-eks module's state)
aws eks update-kubeconfig --region us-east-1 --name $(cd modules/05-eks && terraform output -raw cluster_id)

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
| `general` | KMS rotation on, EKS secrets encrypted with the CMK from 01-kms |
| `hipaa` | Same as `general` — see `modules/*/tfvars/hipaa.tfvars` header comments for why there's no additional divergence today |
| `pci` | Same as `general` — see `modules/*/tfvars/pci.tfvars` header comments for why there's no additional divergence today |

Apply a profile to any module with `./scripts/apply-module.sh <module> <env> <region> <profile>`.

---

## Key outputs

Each module's outputs live in its own state — run `terraform output` from inside that module's directory:

```bash
(cd modules/05-eks && terraform output cluster_id)             # EKS cluster name
(cd modules/05-eks && terraform output cluster_endpoint)       # EKS API server endpoint
(cd modules/02-s3 && terraform output bucket_id)                # S3 bucket for long-term logs
(cd modules/01-kms && terraform output key_arn)                 # CMK
(cd modules/03-network && terraform output vpc_id)               # VPC ID
```

---

## Project structure

```
arc-eks-observability-blueprint/
├── bootstrap/                 # creates the S3 + DynamoDB state backend (apply first)
│   ├── main.tf · variables.tf · outputs.tf
├── modules/                   # each folder is an independent Terraform root
│   ├── 01-kms/
│   │   ├── config.hcl         # static backend key
│   │   ├── main.tf            # own backend "s3" {}, own provider, own module block
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── tfvars/{general,hipaa,pci}.tfvars
│   ├── 02-s3/
│   ├── 03-network/
│   ├── 04-security-group/
│   ├── 05-eks/
│   ├── 06-eks-addon/
│   └── 07-observability/
├── scripts/
│   └── apply-module.sh        # apply one module with a chosen compliance profile
├── Makefile                   # bootstrap / init / plan / apply / validate / fmt
├── .terraform-version         # tfenv pin (1.9.8)
├── sample-app/                # Dockerized app emitting logs/metrics to prove the stack works
├── docs/
│   ├── INSTALL.md             # macOS · Linux · Windows setup guide
│   └── DEPLOYMENT.md          # full deployment + dashboard access + rollback
├── GETTING-STARTED.md         # beginner walkthrough
├── CONTRIBUTING.md
├── CHANGELOG.md · LICENSE · NOTICE · VERSION
└── README.md
```

---

## Documentation

- **[GETTING-STARTED.md](GETTING-STARTED.md)** — zero-to-live walkthrough for first-timers
- **[docs/INSTALL.md](docs/INSTALL.md)** — install Terraform, AWS CLI, and kubectl on macOS / Linux / Windows
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** — full deployment guide, dashboard access, log queries, rollback
- **`modules/*/tfvars/{general,hipaa,pci}.tfvars`** — per-module compliance-profile example files

---

## Important notes

- **Independent state, ordered apply** — each `modules/NN-name/` is its own Terraform root with its own S3 backend. There is no `depends_on` chain across modules; apply ordering (01 → 07) is enforced by the Makefile's numeric directory iteration, not by Terraform itself. Applying out of order will fail `terraform_remote_state` lookups for modules with dependencies (02, 04, 05, 06).
- **EKS addons before observability** — apply `06-eks-addon` before `07-observability` so VPC CNI and EBS CSI are ready before Helm charts deploy. `make apply` and `make init`/`make plan` already do this in the correct order.
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
