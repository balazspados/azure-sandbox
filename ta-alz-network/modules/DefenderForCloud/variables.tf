variable "plans" {
  description = "Map of Microsoft Defender for Cloud plans to set on this subscription. Key = azurerm_security_center_subscription_pricing resource_type (e.g. \"CloudPosture\", \"VirtualMachines\", \"StorageAccounts\")."
  type = map(object({
    tier    = string           # "Free" or "Standard"
    subplan = optional(string) # only some resource_types support/require this

  }))
}
