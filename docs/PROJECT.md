# Project Writeup: AWS Multi-Account Landing Zone

Why this exists, how it was built, why each choice, and the benefits. Also the talking-track for interviews.

## 1. The problem it solves

A single AWS account does not scale safely. As soon as more than one team or environment shares it you get: blast radius (one mistake affects everything), no separation between dev and prod, inconsistent security, and no central audit trail. The industry answer is a multi-account landing zone: many accounts under one Organization, grouped into OUs, with guardrails and a security baseline applied centrally. This project builds that as code, reproducible and reviewable rather than clicked together by hand.

## 2. How it was built

Modular Terraform, applied from the Organization management account:

1. Organization enabled with the service accesses the baseline needs and SERVICE_CONTROL_POLICY enabled.
2. OU structure (modules/organization): Security, Infrastructure, Workloads/{dev,prod}, Sandbox. Accounts placed by function.
3. Guardrails (modules/scp): Service Control Policies attached to OUs.
4. Security baseline (modules/security-baseline): organization CloudTrail into a hardened, encrypted, versioned S3 bucket; GuardDuty; IAM Access Analyzer at org scope.
5. CI identity (modules/oidc-github, modules/oidc-gitlab): OIDC providers and deploy roles so pipelines assume short-lived credentials instead of static keys.

## 3. Why each choice

- AWS Organizations + OUs: guardrails and baselines applied to an OU once are inherited by every account in it, so new accounts are governed automatically.
- Service Control Policies: the only control that limits what even an account root user can do. They set the outer boundary; IAM narrows within it.
- The specific guardrails: deny leaving the org (no escaping governance); protect security services (nobody can silently disable CloudTrail, Config or GuardDuty to hide activity); region restriction (smaller attack surface and cost control, global services excepted).
- Organization CloudTrail, not per-account: one immutable, validated audit log for the whole org, in a bucket with public access blocked, KMS encryption and versioning.
- OIDC deploy roles, not access keys: pipelines exchange a short-lived token for temporary credentials, so there is no long-lived secret to leak.
- Sandbox OU with looser rules: a safe place to experiment without weakening production guardrails.

## 4. Benefits

- Contained blast radius: a mistake or compromise in one account does not reach others.
- Governance by default: new accounts inherit guardrails and logging on joining an OU.
- Tamper-evident audit: a central, validated CloudTrail no member account can stop.
- No static cloud keys in CI: OIDC removes the biggest credential-leak risk.
- Reproducible and reviewable: the whole org is a Terraform diff, peer-reviewed like any code.
- Cost and attack-surface control: region restriction and consistent tagging keep both predictable.

## 5. Interview talking points

- SCP vs IAM policy: SCPs set the maximum permission boundary for an account (including root); IAM grants within it. An action needs both to be allowed.
- Why protect security services with an SCP: stops an attacker with admin from disabling logging to cover tracks.
- Why OIDC over access keys: short-lived credentials, nothing to rotate or leak, scoped to a specific repo and branch via the trust condition.
- Avoiding lockout: deny SCPs exclude the management account and a break-glass admin role; always plan and read the diff first.
- What to add next: IAM Identity Center permission sets, dedicated log-archive and audit accounts, Config conformance packs, and automated account vending.

## 6. How to run it

```bash
cd envs/management
terraform init
terraform plan   # read the diff carefully, these are org-level changes
terraform apply
```

Run from the Organization management account. SCPs can lock you out if misused, so review every plan before applying.