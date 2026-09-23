locals {
  resource_guard_deployment = {
    rgd_name = "${local.alz_config.org_id}rgdbackup${local.alz_config.environment}${local.alz_config.azure_region_location_short}001" # The name must be between 5 and 50 characters long and can only contain lowercase letters and numbers.

  }
}