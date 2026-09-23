
module "des_identity" {
  source  = "Azure/avm-res-compute-diskencryptionset/azurerm"
  version = "0.1.1" # https://github.com/Azure/terraform-azurerm-avm-res-compute-diskencryptionset
  providers = {
    azurerm = azurerm.identity
    azapi   = azapi.identity
  }
  key_vault_key_id      = module.key_vault_identity.keys.cmk_for_disk_encryption.versionless_id
  key_vault_resource_id = module.key_vault_identity.resource_id
  location              = local.alz_config.azure_region_location
  name                  = local.des_identity_parameters.des_name
  resource_group_name   = local.rg_identity_001.name
  encryption_type       = "EncryptionAtRestWithCustomerKey"

  enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags

  auto_key_rotation_enabled = true
  managed_identities = {
    system_assigned = true
  }

}
