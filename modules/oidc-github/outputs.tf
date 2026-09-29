output "deploy_role_arn" {
  description = "Use this ARN as role-to-assume in the GitHub Actions workflow."
  value       = aws_iam_role.deploy.arn
}
