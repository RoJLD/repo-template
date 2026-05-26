# Infrastructure-as-Code

`infra/` holds all deployment definitions, separate from application code.

## Layout

```
infra/
├── terraform/       # Terraform / OpenTofu modules
├── k8s/             # Kubernetes manifests
├── helm/            # Helm charts
└── cloudformation/  # AWS CloudFormation (if applicable)
```

Use only the subfolders relevant to your stack.

## Scanning

The `infra/` folder is scanned on every push by Checkov via
`.github/workflows/iac-scan.yml`. High-severity findings fail the build.

## Local scan

```bash
pip install checkov
checkov -d infra/ --framework all
```

Or with Docker :

```bash
docker run --rm -v $(pwd):/repo bridgecrew/checkov -d /repo/infra
```

## Conventions

- Never commit `.tfstate` files (in `.gitignore`)
- Never commit credentials — use environment variables or secret managers
- Tag every cloud resource with `Project={{PROJECT_NAME}}` and `Env={dev|staging|prod}`
