locals {
  alz_subscriptions_parameters = {
    subscription_workload          = "Production"
    subscription_billing_scope     = "/providers/Microsoft.Billing/billingAccounts/793881c2-1dbc-58a7-97e1-997069604e23:342d4565-b5af-41dc-9fe6-08e3ac703fcf_2019-05-31/billingProfiles/OQ2N-URE4-BG7-PGB/invoiceSections/64f11abe-ab87-4848-b66b-d6db65b74389"
    management_subscription_name   = "${local.alz_config.org_id}-sub-mgmt-001"
    connectivity_subscription_name = "${local.alz_config.org_id}-sub-nw-001"
    security_subscription_name     = "${local.alz_config.org_id}-sub-sec-001"
    identity_subscription_name     = "${local.alz_config.org_id}-sub-idn-001"
  }
}