# Enable AWS Organizations with the service accesses needed for the baseline.
resource "aws_organizations_organization" "this" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "access-analyzer.amazonaws.com",
    "sso.amazonaws.com",
  ]
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
  feature_set          = "ALL"
}

module "organization" {
  source  = "../../modules/organization"
  root_id = aws_organizations_organization.this.roots[0].id
}

module "scp" {
  source = "../../modules/scp"

  allowed_regions = var.allowed_regions

  # Apply the core guardrails to all workload OUs plus infrastructure and security.
  guardrail_target_ids = [
    module.organization.security_ou_id,
    module.organization.infrastructure_ou_id,
    module.organization.workloads_dev_ou_id,
    module.organization.workloads_prod_ou_id,
  ]

  # Region restriction everywhere except Sandbox, where experimentation is allowed.
  region_restricted_target_ids = [
    module.organization.infrastructure_ou_id,
    module.organization.workloads_dev_ou_id,
    module.organization.workloads_prod_ou_id,
  ]
}

module "security_baseline" {
  source            = "../../modules/security-baseline"
  trail_bucket_name = var.trail_bucket_name
}

module "oidc_github" {
  source = "../../modules/oidc-github"
}
