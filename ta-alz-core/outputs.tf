output "alz_config" {
  description = "Platform config shared with ALZ workspaces"
  value = {

    resource_group_management_terraform = azurerm_resource_group.rg_management.name
    org_id                              = local.alz_config.org_id
    azure_region_location_short         = local.alz_config.azure_region_location_short
    azure_region_location               = local.alz_config.azure_region_location
    platform_costcenter                 = local.alz_config.platform_costcenter
    environment                         = local.alz_config.environment
    telemetry_enabled                   = local.alz_config.telemetry_enabled
    management_subscription_id          = local.alz_config.management_subscription_id
    management_subscription_MG_name     = local.alz_config.management_subscription_MG_name
    connectivity_subscription_id        = local.alz_config.connectivity_subscription_id
    connectivity_subscription_MG_name   = local.alz_config.connectivity_subscription_MG_name
    identity_subscription_id            = local.alz_config.identity_subscription_id
    identity_subscription_MG_name       = local.alz_config.identity_subscription_MG_name
    security_subscription_id            = local.alz_config.security_subscription_id
    security_subscription_MG_name       = local.alz_config.security_subscription_MG_name
    azure_tenant_id                     = local.alz_config.azure_tenant_id
    resource_lock_kind                  = local.alz_config.resource_lock_kind
  }
}

output "platform_log_analytics_workspace_id" {
  description = "Platform LAW resource ID"
  value       = module.alz_management.log_analytics_workspace.id
}

output "management_group_resource_ids" {
  description = "Map of management group id (e.g. \"alz\", \"platform\", \"connectivity\", \"identity\") to its fully-qualified Azure resource ID, as created by the alz_architecture module."
  value       = module.alz_architecture.management_group_resource_ids
}

output "resource_guard_deployment_id" {
  description = "Resource ID of the platform Resource Guard Deployment, used to enable MUA on Recovery Services Vaults"
  value       = replace(module.resource_guard_deployment.resource_id, "ResourceGuards", "resourceGuards")
  ## Known issue !!!
  ## this isn't a config issue with your wiring, it's a casing bug in the avm-res-dataprotection-resourceguard module (the only published version, 0.1.0). 
  ## Its vendored source declares the azapi resource type as: type = "Microsoft.DataProtection/ResourceGuards@2022-05-01"
  ## (capital R/G — ta-alz-core/.terraform/modules/resource_guard_deployment/main.tf:4). ARM's API is case-insensitive so the resource itself deploys fine, 
  ## but the id the module outputs inherits that wrong casing verbatim. azurerm_recovery_services_vault_resource_guard_association.resource_guard_id uses 
  ## azurerm's strongly-typed ID parser, which requires the exact literal resourceGuards — hence the parse error you're seeing. There's no newer module 
  ## version to upgrade to (0.1.0 is the only release), so it needs a workaround at the point where you expose/consume the ID
}

output "rg_management" {
  description = "Management resource group's parameters"
  value = {
    id   = azurerm_resource_group.rg_management.id
    name = azurerm_resource_group.rg_management.name
  }
}
