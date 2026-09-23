locals {
  identity_recovery_vault_parameters = {
    name                                         = "${local.alz_config.org_id}-rsv-backup-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    sku                                          = "RS0"           # Default : "RS0"
    storage_mode_type                            = "ZoneRedundant" # See ALZ document page 90
    private_endpoint_name                        = "pep-${local.alz_config.org_id}-rsv-backup-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    private_endpoints_subnet_id                  = data.terraform_remote_state.alz_network.outputs.private_endpoints_subnet.id
    private_endpoints_subnet_resource_group_name = data.terraform_remote_state.alz_network.outputs.private_endpoints_subnet.resource_group
    private_dns_zone_id                          = data.terraform_remote_state.alz_network.outputs.private_dns_zone_resource_ids["azure_backup"]
    public_network_access_enabled                = false
    cross_region_restore_enabled                 = false # CRR is only valid when storage_mode_type = "GeoRedundant"
    resource_guard_deployment_id                 = data.terraform_remote_state.alz.outputs.resource_guard_deployment_id
    soft_delete_enabled                          = "Enabled" # Default: "Enabled" or "Disabled" or "AlwaysOn"


    vm_backup_policy = {
      "OS-tier1-Hourly" = {
        name                           = "OS-tier1-Hourly"
        timezone                       = "New Zealand Standard Time"
        instant_restore_retention_days = 1
        policy_type                    = "V2"
        frequency                      = "Hourly"
        backup = {
          time          = "00:00"
          hour_interval = 4
          hour_duration = 24
        }
        retention_daily = 30
        retention_monthly = {
          count = 12
          days  = [1]
        }
        retention_yearly = {
          count  = 7
          months = ["January"]
          days   = [1]
        }
      }

      "OS-tier2-Daily" = {
        name                           = "OS-tier2-Daily"
        timezone                       = "New Zealand Standard Time"
        instant_restore_retention_days = 2
        policy_type                    = "V2"
        frequency                      = "Daily"
        backup = {
          time = "20:00"
        }
        retention_daily = 30
        retention_monthly = {
          count = 12
          days  = [1]
        }
        retention_yearly = {
          count  = 7
          months = ["January"]
          days   = [1]
        }
      }

      "OS-tier3-short-term" = {
        name                           = "OS-tier3-short-term"
        timezone                       = "New Zealand Standard Time"
        instant_restore_retention_days = 7 # Must be specified. Default value is 7. Otherwise azapi keeps updating every single deployment.
        policy_type                    = "V2"
        frequency                      = "Daily"
        backup = {
          time = "20:00"
        }
        retention_daily = 30
      }
    }

    workload_backup_policy = {
      "SQL-tier-1" = {
        name          = "SQL-tier-1"
        workload_type = "SQLDataBase"
        settings = {
          time_zone           = "New Zealand Standard Time"
          compression_enabled = true
        }
        backup_frequency = "Daily"
        protection_policy = {
          full = {
            policy_type           = "Full"
            retention_daily_count = 30
            backup = {
              time = "19:00"
            }
            retention_monthly = {
              count     = 12
              monthdays = [1]
            }
            retention_yearly = {
              count     = 7
              months    = ["January"]
              monthdays = [1]
            }
          }
          log = {
            policy_type           = "Log"
            retention_daily_count = 30
            backup = {
              frequency_in_minutes = 60
            }
          }
        }
      }

      "SQL-tier-2" = {
        name          = "SQL-tier-2"
        workload_type = "SQLDataBase"
        settings = {
          time_zone           = "New Zealand Standard Time"
          compression_enabled = true
        }
        backup_frequency = "Daily"
        protection_policy = {
          full = {
            policy_type           = "Full"
            retention_daily_count = 30
            backup = {
              time = "19:00"
            }
            retention_monthly = {
              count     = 12
              monthdays = [1]
            }
            retention_yearly = {
              count     = 7
              months    = ["January"]
              monthdays = [1]
            }
          }
        }
      }

      "SQL-tier-short-term" = {
        name          = "SQL-tier-short-term"
        workload_type = "SQLDataBase"
        settings = {
          time_zone           = "New Zealand Standard Time"
          compression_enabled = true
        }
        backup_frequency = "Daily"
        protection_policy = {
          full = {
            policy_type           = "Full"
            retention_daily_count = 30
            backup = {
              time = "18:00"
            }
          }
        }
      }
    }
  }
}