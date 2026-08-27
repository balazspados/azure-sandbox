variable "platform_costcenter" {
  type    = string
  default = "XXX"
}

variable "org_prefix" {
  type    = string
  default = "XXX"
  validation {
    error_message = "Length must be between 3 and 5 characters."
    condition     = length(var.org_prefix) >= 3 && length(var.org_prefix) <= 5
  }
}

variable "azure_region" {
  type = map(string)
  default = {
    location       = ""
    location_short = ""
  }
}

variable "environment" {
  type    = string
  default = "platform"
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Enable telemetry for the module."
  nullable    = false
}

variable "security_subscription" {
  type        = map(string)
  description = "Security subscription details "
  default = {
    id      = ""
    MG_name = "security"
  }
}

variable "connectivity_subscription" {
  type        = map(string)
  description = "Connectivity subscription details"
  default = {
    id      = ""
    MG_name = "connectivity"
  }
}

variable "identity_subscription" {
  type        = map(string)
  description = "Identity subscription details"
  default = {
    id      = ""
    MG_name = "identity"
  }
}

variable "management_subscription" {
  type        = map(string)
  description = "Management subscription details"
  default = {
    id      = ""
    MG_name = "management"
  }
}

variable "azure_tenant" {
  type        = map(string)
  description = "Management subscription details"
  default = {
    id = ""
  }
}