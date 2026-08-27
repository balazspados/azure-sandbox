output "alz_config" {
  description = "Platform config shared with ALZ workspaces"
  value = {

    resource_group_management_terraform = azurerm_resource_group.rg_management.name
    org_prefix                          = var.org_prefix
    azure_region_location_short         = var.azure_region.location_short
    azure_region_location               = var.azure_region.location
    platform_costcenter                 = var.platform_costcenter
    environment                         = var.environment
    telemery_enable                     = var.enable_telemetry
    management_subscription_id          = var.management_subscription.id
    management_subscription_MG_name     = var.management_subscription.MG_name
    connectivity_subscription_id        = var.connectivity_subscription.id
    connectivity_subscription_MG_name   = var.connectivity_subscription.MG_name
    identity_subscription_id            = var.identity_subscription.id
    identity_subscription_MG_name       = var.identity_subscription.MG_name
    security_subscription_id            = var.security_subscription.id
    security_subscription_MG_name       = var.security_subscription.MG_name
    azure_tenant_id                     = var.azure_tenant.id
  }
}
