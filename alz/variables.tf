
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