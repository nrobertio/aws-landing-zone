# Guardrail 1: prevent member accounts from leaving the organization.
data "aws_iam_policy_document" "deny_leave_org" {
  statement {
    sid       = "DenyLeaveOrg"
    effect    = "Deny"
    actions   = ["organizations:LeaveOrganization"]
    resources = ["*"]
  }
}

# Guardrail 2: prevent disabling core security services.
data "aws_iam_policy_document" "protect_security" {
  statement {
    sid    = "DenyDisableSecurity"
    effect = "Deny"
    actions = [
      "guardduty:DeleteDetector",
      "guardduty:DisassociateFromMasterAccount",
      "config:DeleteConfigurationRecorder",
      "config:StopConfigurationRecorder",
      "cloudtrail:StopLogging",
      "cloudtrail:DeleteTrail",
    ]
    resources = ["*"]
  }
}

# Guardrail 3: restrict usage to approved regions (global services excepted).
data "aws_iam_policy_document" "region_restriction" {
  statement {
    sid    = "DenyUnapprovedRegions"
    effect = "Deny"
    not_actions = [
      "iam:*", "organizations:*", "route53:*", "cloudfront:*",
      "waf:*", "support:*", "sts:*", "budgets:*",
    ]
    resources = ["*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = var.allowed_regions
    }
  }
}

resource "aws_organizations_policy" "deny_leave_org" {
  name    = "deny-leave-org"
  type    = "SERVICE_CONTROL_POLICY"
  content = data.aws_iam_policy_document.deny_leave_org.json
}

resource "aws_organizations_policy" "protect_security" {
  name    = "protect-security-services"
  type    = "SERVICE_CONTROL_POLICY"
  content = data.aws_iam_policy_document.protect_security.json
}

resource "aws_organizations_policy" "region_restriction" {
  name    = "region-restriction"
  type    = "SERVICE_CONTROL_POLICY"
  content = data.aws_iam_policy_document.region_restriction.json
}

# Attach guardrails to the OUs that should be constrained.
resource "aws_organizations_policy_attachment" "leave_org" {
  for_each  = toset(var.guardrail_target_ids)
  policy_id = aws_organizations_policy.deny_leave_org.id
  target_id = each.value
}

resource "aws_organizations_policy_attachment" "protect_security" {
  for_each  = toset(var.guardrail_target_ids)
  policy_id = aws_organizations_policy.protect_security.id
  target_id = each.value
}

resource "aws_organizations_policy_attachment" "region_restriction" {
  for_each  = toset(var.region_restricted_target_ids)
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = each.value
}
