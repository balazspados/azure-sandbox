variable "platform_costcenter" {
  type    = string
  default = "XXX"
}

variable "org_prefix" {
  type    = string
  default = "XXX"
  validation {
    error_message = "Length must be between 1 and 40 characters."
    condition     = length(var.org_prefix) > 0 && length(var.org_prefix) <= 5
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