variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "allowed_regions" {
  type    = list(string)
  default = ["eu-central-1", "eu-west-1"]
}

variable "trail_bucket_name" {
  description = "Globally unique bucket name for org CloudTrail."
  type        = string
}
