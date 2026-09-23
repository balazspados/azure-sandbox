### Create LAW security resources

### Create Private Endpoint in endpoint subnet
resource "azurerm_monitor_private_link_scope" "ampls_law_security" {
  provider            = azurerm.security
  name                = local.law_security_parameters.monitor_private_link_scope_name
  resource_group_name = azurerm_resource_group.rg_law_security.name
  tags                = local.common_tags
}

resource "azurerm_monitor_private_link_scoped_service" "law_security" {
  provider            = azurerm.security
  name                = local.law_security_parameters.monitor_private_link_scoped_service_name
  resource_group_name = azurerm_resource_group.rg_law_security.name
  scope_name          = azurerm_monitor_private_link_scope.ampls_law_security.name
  linked_resource_id  = module.law_security.resource_id
}

resource "azurerm_private_endpoint" "pep_law_security" {
  provider            = azurerm.connectivity
  name                = local.law_security_parameters.private_endpoint_name
  location            = local.alz_config.azure_region_location
  resource_group_name = local.law_security_parameters.private_endpoints_subnet_resource_group_name
  subnet_id           = local.law_security_parameters.private_endpoints_subnet_id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-${local.law_security_parameters.private_endpoint_name}"
    private_connection_resource_id = azurerm_monitor_private_link_scope.ampls_law_security.id
    subresource_names              = ["azuremonitor"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dnslinktovnet"
    private_dns_zone_ids = local.law_security_parameters.private_dns_zone_ids
  }
}


### Create LAW security

module "law_security" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1" # https://github.com/Azure/terraform-azurerm-avm-res-operationalinsights-workspace
  providers = {
    azurerm = azurerm.security
  }
  location            = local.alz_config.azure_region_location
  name                = local.law_security_parameters.law_name
  resource_group_name = azurerm_resource_group.rg_law_security.name

  log_analytics_workspace_internet_ingestion_enabled = local.law_security_parameters.log_analytics_workspace_internet_ingestion_enabled
  log_analytics_workspace_internet_query_enabled     = local.law_security_parameters.log_analytics_workspace_internet_query_enabled
  log_analytics_workspace_retention_in_days          = local.law_security_parameters.log_analytics_workspace_retention_in_days
  log_analytics_workspace_sku = local.law_security_parameters.log_analytics_workspace_sku
  enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags


  log_analytics_workspace_identity = {
    type = "SystemAssigned"
  }
}