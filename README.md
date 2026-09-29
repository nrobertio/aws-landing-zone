# AWS Multi-Account Landing Zone

A Terraform reference for a secure, multi-account **AWS Organization**: an organizational unit (OU) structure, **Service Control Policy (SCP) guardrails**, an org-wide **security baseline** (CloudTrail, Config, GuardDuty, IAM Access Analyzer), centralized logging, and **OIDC-based CI deploy roles** with no long-lived keys.

> Maintained by [nrobertio](https://github.com/nrobertio). A generic, public reference for the multi-account AWS governance work I do day to day.

## What this demonstrates

- **AWS Organizations** with a sensible OU layout (Security, Infrastructure, Workloads/{dev,prod}, Sandbox).
- **SCP guardrails**: deny leaving the org, deny disabling security services, restrict regions, deny root user actions.
- **Security baseline**: organization CloudTrail to a locked-down S3 bucket, AWS Config, GuardDuty, IAM Access Analyzer.
- **Least-privilege CI/CD**: GitHub Actions and GitLab OIDC roles that assume into accounts with no static credentials.
- **Everything in Terraform**, modular and reviewable.

## Architecture

See [docs/PROJECT.md](docs/PROJECT.md). High level:

```
Management account (Organizations, SCPs, consolidated CloudTrail)
  |-- Security OU        (audit + log-archive accounts, GuardDuty admin)
  |-- Infrastructure OU  (shared services, networking)
  |-- Workloads OU
  |     |-- dev
  |     |-- prod
  |-- Sandbox OU         (loose guardrails for experimentation)
```

## Layout

```
modules/
  organization/     OUs and account placement
  scp/              Service Control Policy guardrails
  security-baseline/ CloudTrail, Config, GuardDuty, Access Analyzer
  oidc-github/      GitHub Actions OIDC provider + deploy role
  oidc-gitlab/      GitLab OIDC provider + deploy role
envs/
  management/       root of the org: calls the modules
docs/
  PROJECT.md        why, how, benefits, interview notes
```

## Usage

```bash
cd envs/management
terraform init
terraform plan
terraform apply
```

Run from the Organization management account. Review `terraform.tfvars.example` and copy to `terraform.tfvars`.

## Safety note

SCPs can lock you out if misused. The deny policies here exclude the management account and an admin break-glass role. Always `terraform plan` and read the diff before applying org-level changes.

## License

MIT. See [LICENSE](LICENSE).
