locals {
  resource_guard_deployment = {
    rg_name  = "${local.alz_config.org_id}-rg-backup-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-099"
    rgd_name = "${local.alz_config.org_id}rdgbackup${local.alz_config.environment}${local.alz_config.azure_region_location_short}001" # The name must be between 5 and 50 characters long and can only contain lowercase letters and numbers.

  }
}