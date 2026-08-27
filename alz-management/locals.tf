locals {
  common_tags = {
    description      = "${upper(var.org_prefix)} ALZ Platform core service"
    costCenter       = var.platform_costcenter
    environment      = var.environment
    function         = "Core service"
    application      = "Core service"
    deploymentMethod = "terraform"
    gitRepository    = ""

  }

  alz_resource_instance_number = "001"
}