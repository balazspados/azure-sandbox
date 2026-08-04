# Include the additional policies and override archetypes
provider "alz" {
  library_overwrite_enabled = true
  library_references = [
    { path = "platform/alz"
      ref  = "2026.04.2" # check registry for current ref https://github.com/Azure/Azure-Landing-Zones-Library/releases
    },
    {
      "path" : "platform/amba",
      "ref" : "2026.06.2" # https://github.com/Azure/Azure-Landing-Zones-Library/releases#release-platform/amba/
    },
    {
      custom_url = "${path.root}/lib"
    }
  ]
  suppress_warning_policy_role_assignments = true
}


data "azapi_client_config" "current" {}

module "alz_architecture" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.21.0"

  architecture_name  = "custom_alz"
  location           = local.azure_region.name
  parent_resource_id = data.azapi_client_config.current.tenant_id
  #   enable_telemetry   = var.enable_telemetry

  subscription_placement = {
    management = {
      subscription_id       = "8b7867e2-e2b3-468e-b0ee-68da980c2eee"
      management_group_name = "management"
    },
    connectivity = {
      subscription_id       = "c7cf7d65-b00e-411a-b252-1394a56b3b5f"
      management_group_name = "connectivity"
    },
    identity = {
      subscription_id       = "701ff494-fc7f-4e23-8849-9220a67c8a5e"
      management_group_name = "identity"
    }
  }

}