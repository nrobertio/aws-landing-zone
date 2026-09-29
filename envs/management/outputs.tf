output "org_id" {
  value = aws_organizations_organization.this.id
}

output "github_deploy_role_arn" {
  value = module.oidc_github.deploy_role_arn
}
