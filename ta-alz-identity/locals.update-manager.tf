locals {
  update_manager_parameters = {
    # rg_name = "${local.alz_config.org_id}-rg-update_manager-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    osupdate_001 = {
      name                     = "${local.alz_config.org_id}-mc-osupdate-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
      recur_every              = "4Weeks Thursday"
      start_date_time          = "2026-09-10 22:00"
      duration                 = "03:55" # Max value
      time_zone                = "New Zealand Standard Time"
      scope                    = "InGuestPatch"
      scope_InGuestPatchMode   = "User" # Can either 'Platform' or 'User'
      reboot_setting           = "IfRequired"
      windows_included_updates = ["Critical", "Security"]
      linux_included_updates   = ["Critical", "Security"]
    }
    osupdate_002 = {
      name                     = "${local.alz_config.org_id}-mc-osupdate-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-002"
      recur_every              = "4Weeks Thursday"
      start_date_time          = "2026-09-17 22:00"
      duration                 = "03:55" # Max value
      time_zone                = "New Zealand Standard Time"
      scope                    = "InGuestPatch"
      scope_InGuestPatchMode   = "User" # Can either 'Platform' or 'User'
      reboot_setting           = "IfRequired"
      windows_included_updates = ["Critical", "Security"]
      linux_included_updates   = ["Critical", "Security"]
    }
    defupdate_001 = {
      name                     = "${local.alz_config.org_id}-mc-defupdate-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
      recur_every              = "Day"
      start_date_time          = "2026-09-08 20:00"
      duration                 = "02:00"
      time_zone                = "New Zealand Standard Time"
      scope                    = "InGuestPatch"
      scope_InGuestPatchMode   = "User" # Can either 'Platform' or 'User'
      reboot_setting           = "IfRequired"
      windows_included_updates = ["Definition"]
      linux_included_updates   = []
    }
  }
}