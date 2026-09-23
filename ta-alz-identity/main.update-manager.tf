### Create Update Manager 


module "update_manager_osupdate_001" {
  source  = "Azure/avm-res-maintenance-maintenanceconfiguration/azurerm"
  version = "0.1.0" # https://github.com/Azure/terraform-azurerm-avm-res-maintenance-maintenanceconfiguration
  providers = {
    azurerm = azurerm.identity
    azapi   = azapi.identity
  }
  location            = local.alz_config.azure_region_location
  name                = local.update_manager_parameters.osupdate_001.name
  resource_group_name = local.rg_management.name
  scope               = local.update_manager_parameters.osupdate_001.scope
  extension_properties = {
    InGuestPatchMode = local.update_manager_parameters.osupdate_001.scope_InGuestPatchMode
  }

  window = {
    recur_every     = local.update_manager_parameters.osupdate_001.recur_every
    start_date_time = local.update_manager_parameters.osupdate_001.start_date_time
    duration        = local.update_manager_parameters.osupdate_001.duration
    time_zone       = local.update_manager_parameters.osupdate_001.time_zone
  }
  install_patches = {
    reboot_setting = local.update_manager_parameters.osupdate_001.reboot_setting
    windows = {
      classifications_to_include = local.update_manager_parameters.osupdate_001.windows_included_updates
    }
    linux = {
      classifications_to_include = local.update_manager_parameters.osupdate_001.linux_included_updates
    }
  }
  enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags
}

module "update_manager_osupdate_002" {
  source  = "Azure/avm-res-maintenance-maintenanceconfiguration/azurerm"
  version = "0.1.0" # https://github.com/Azure/terraform-azurerm-avm-res-maintenance-maintenanceconfiguration
  providers = {
    azurerm = azurerm.identity
    azapi   = azapi.identity
  }
  location            = local.alz_config.azure_region_location
  name                = local.update_manager_parameters.osupdate_002.name
  resource_group_name = local.rg_management.name
  scope               = local.update_manager_parameters.osupdate_002.scope
  extension_properties = {
    InGuestPatchMode = local.update_manager_parameters.osupdate_002.scope_InGuestPatchMode
  }

  window = {
    recur_every     = local.update_manager_parameters.osupdate_002.recur_every
    start_date_time = local.update_manager_parameters.osupdate_002.start_date_time
    duration        = local.update_manager_parameters.osupdate_002.duration
    time_zone       = local.update_manager_parameters.osupdate_002.time_zone
  }
  install_patches = {
    reboot_setting = local.update_manager_parameters.osupdate_002.reboot_setting
    windows = {
      classifications_to_include = local.update_manager_parameters.osupdate_002.windows_included_updates
    }
    linux = {
      classifications_to_include = local.update_manager_parameters.osupdate_002.linux_included_updates
    }
  }
  enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags
}

module "update_manager_defupdate_001" {
  source  = "Azure/avm-res-maintenance-maintenanceconfiguration/azurerm"
  version = "0.1.0" # https://github.com/Azure/terraform-azurerm-avm-res-maintenance-maintenanceconfiguration
  providers = {
    azurerm = azurerm.identity
    azapi   = azapi.identity
  }
  location            = local.alz_config.azure_region_location
  name                = local.update_manager_parameters.defupdate_001.name
  resource_group_name = local.rg_management.name
  scope               = local.update_manager_parameters.defupdate_001.scope
  extension_properties = {
    InGuestPatchMode = local.update_manager_parameters.defupdate_001.scope_InGuestPatchMode
  }

  window = {
    recur_every     = local.update_manager_parameters.defupdate_001.recur_every
    start_date_time = local.update_manager_parameters.defupdate_001.start_date_time
    duration        = local.update_manager_parameters.defupdate_001.duration
    time_zone       = local.update_manager_parameters.defupdate_001.time_zone
  }
  install_patches = {
    reboot_setting = local.update_manager_parameters.defupdate_001.reboot_setting
    windows = {
      classifications_to_include = local.update_manager_parameters.defupdate_001.windows_included_updates
    }
    linux = {
      classifications_to_include = local.update_manager_parameters.defupdate_001.linux_included_updates
    }
  }
  enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags
}