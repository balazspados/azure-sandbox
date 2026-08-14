locals {
  common_tags = {
    description      = "${upper(var.org_prefix)} ALZ Platform"
    costCenter       = var.platform_costcenter
    environment      = var.environment
    function         = "${upper(var.org_prefix)} ALZ Platform"
    application      = "${upper(var.org_prefix)} ALZ Platform"
    deploymentMethod = "terraform"
    gitRepository    = ""

  }

  alz_resource_instace_number = "001"
}