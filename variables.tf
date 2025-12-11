variable "artifactory_access_token" {
  description = "Access token for the Artifactory provider."
  type        = string
  sensitive   = true
}

variable "xray_access_token" {
  description = "Access token for the Xray provider."
  type        = string
  sensitive   = true
}

