locals {
  common_tags = {
    environment = "platform"
    managed_by  = "terraform"
    purpose     = "alz-management"
    cost_center = "XXX"
  }
  azure_region = {
    name       = "newzealandnorth"
    short_name = "nzn"
  }
}