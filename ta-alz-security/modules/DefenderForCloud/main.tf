resource "azurerm_security_center_subscription_pricing" "this" {
  for_each = var.plans

  tier          = each.value.tier
  resource_type = each.key
  ### Possible resource_type values are AI, Api, AppServices, ContainerRegistry, KeyVaults, KubernetesService, SqlServers, SqlServerVirtualMachines, StorageAccounts, VirtualMachines, Arm, Dns, OpenSourceRelationalDatabases, Containers, CosmosDbs and CloudPosture
  ### https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing
  subplan = each.value.subplan
}