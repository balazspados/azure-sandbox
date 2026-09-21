module "subscription_management" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "0.3.2"

  location = local.alz_config.azure_region_location

  # Existing subscription — do not create a new one. Management-group placement stays owned by module.alz_architecture's subscription_placement
  subscription_id              = local.alz_config.management_subscription_id
  subscription_update_existing = true
  subscription_display_name    = local.alz_subscriptions_parameters.management_subscription_name
  subscription_tags            = local.common_tags

  enable_telemetry = local.alz_config.telemetry_enabled
}

module "subscription_connectivity" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "0.3.2"

  location = local.alz_config.azure_region_location

  # Existing subscription — do not create a new one. Management-group placement stays owned by module.alz_architecture's subscription_placement
  subscription_id              = local.alz_config.connectivity_subscription_id
  subscription_update_existing = true
  subscription_display_name    = local.alz_subscriptions_parameters.connectivity_subscription_name
  subscription_tags            = local.common_tags

  enable_telemetry = local.alz_config.telemetry_enabled
}

module "subscription_security" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "0.3.2"

  location = local.alz_config.azure_region_location

  # Existing subscription — do not create a new one. Management-group placement stays owned by module.alz_architecture's subscription_placement
  subscription_id              = local.alz_config.security_subscription_id
  subscription_update_existing = true
  subscription_display_name    = local.alz_subscriptions_parameters.security_subscription_name
  subscription_tags            = local.common_tags

  enable_telemetry = local.alz_config.telemetry_enabled
}


module "subscription_identity" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "0.3.2"

  location = local.alz_config.azure_region_location

  subscription_alias_enabled = true # actually calls the API to create a brand-new subscription
  subscription_alias_name    = local.alz_subscriptions_parameters.identity_subscription_name
  subscription_display_name  = local.alz_subscriptions_parameters.identity_subscription_name
  subscription_workload      = local.alz_subscriptions_parameters.subscription_workload
  subscription_billing_scope = local.alz_subscriptions_parameters.subscription_billing_scope

  enable_telemetry = local.alz_config.telemetry_enabled
}



