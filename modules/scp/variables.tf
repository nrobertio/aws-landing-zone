variable "allowed_regions" {
  description = "Regions members may operate in."
  type        = list(string)
  default     = ["eu-central-1", "eu-west-1"]
}

variable "guardrail_target_ids" {
  description = "OU or account IDs that get the leave-org and protect-security guardrails."
  type        = list(string)
}

variable "region_restricted_target_ids" {
  description = "OU or account IDs that get the region restriction (usually not Sandbox)."
  type        = list(string)
}
