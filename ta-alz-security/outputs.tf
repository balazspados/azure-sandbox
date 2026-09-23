output "security_log_analytics_workspace" {
  value = {
    id      = module.law_security.resource_id
    rg_name = azurerm_resource_group.rg_law_security.name
  }
}

