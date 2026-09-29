output "security_ou_id" { value = aws_organizations_organizational_unit.security.id }
output "infrastructure_ou_id" { value = aws_organizations_organizational_unit.infrastructure.id }
output "workloads_dev_ou_id" { value = aws_organizations_organizational_unit.workloads_dev.id }
output "workloads_prod_ou_id" { value = aws_organizations_organizational_unit.workloads_prod.id }
output "sandbox_ou_id" { value = aws_organizations_organizational_unit.sandbox.id }
