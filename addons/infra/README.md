# addon : infra

Infrastructure-as-Code (IaC) scanning and conventions.

## When to add

Your project ships :
- Terraform / OpenTofu (`.tf` files)
- AWS CloudFormation (`.yaml`/`.json` templates)
- Kubernetes manifests (`.yaml` in `k8s/`)
- Helm charts
- Pulumi / CDK code

**Do NOT add this addon** if you just have a Dockerfile + docker-compose.
Those are already covered by the `web` addon. IaC means cloud / cluster
deployment definitions.

## What it adds

| File | Purpose |
|---|---|
| `.github/workflows/iac-scan.yml` | Checkov static analysis on every push |
| `infra/README.md` | Convention for IaC code layout |
| `.gitignore.infra` | Common IaC ignores (`.terraform/`, `*.tfstate`, etc.) — merge into root `.gitignore` |

## Why this works

- **Checkov** scans Terraform / CloudFormation / Helm for security
  misconfigurations (open S3 buckets, missing encryption, etc.)
- Catching IaC bugs at PR time is 10-100× cheaper than catching them
  after deployment
- The convention `infra/` folder separates infrastructure from
  application code — useful when ops and dev teams diverge

## Integration with core template

- `.github/workflows/iac-scan.yml` runs on push to `infra/**` paths
- Append `.gitignore.infra` content to your existing `.gitignore`
- Place IaC code under `infra/{terraform,k8s,helm}/`

## Alternatives to Checkov

- `tfsec` — Terraform-specific, faster
- `kube-linter` — Kubernetes-specific
- `trivy config` — multi-cloud, also scans images
- Choose based on your IaC mix
