# # main.vwan.firewall_policy.tf (proposed new file)

# resource "azurerm_firewall_policy_rule_collection_group" "primary_example" {
#   provider = azurerm.connectivity

#   name                = "${local.alz_config.org_prefix}-afwp-rcg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
#   firewall_policy_id  = module.virtual_wan_hub.firewall_policy_resource_ids["primary"]
#   priority            = 500

#   # --- Example: allow core infra traffic (DNS/NTP) out from hub/spoke ---
#   network_rule_collection {
#     name     = "allow-core-infra"
#     priority = 100
#     action   = "Allow"

#     rule {
#       name                  = "allow-dns"
#       protocols             = ["UDP", "TCP"]
#       source_addresses      = ["10.225.0.0/22"] # placeholder: hub + spoke address space
#       destination_addresses = ["*"]
#       destination_ports     = ["53"]
#     }

#     rule {
#       name                  = "allow-ntp"
#       protocols             = ["UDP"]
#       source_addresses      = ["10.225.0.0/22"]
#       destination_addresses = ["*"]
#       destination_ports     = ["123"]
#     }
#   }

#   # --- Example: allow specific outbound FQDNs (application layer) ---
#   application_rule_collection {
#     name     = "allow-microsoft-fqdns"
#     priority = 200
#     action   = "Allow"

#     rule {
#       name = "allow-windows-update"
#       protocols {
#         type = "Https"
#         port = 443
#       }
#       source_addresses  = ["10.225.0.0/22"]
#       destination_fqdns = ["*.update.microsoft.com", "*.windowsupdate.com"]
#     }
#   }

#   # --- Example: DNAT placeholder (illustrative only, not real IPs) ---
#   nat_rule_collection {
#     name     = "example-dnat"
#     priority = 300
#     action   = "Dnat"

#     rule {
#       name                = "example-rdp"
#       protocols           = ["TCP"]
#       source_addresses    = ["*"]
#       destination_address = "<firewall-public-ip>" # placeholder
#       destination_ports   = ["3389"]
#       translated_address  = "<target-vm-private-ip>" # placeholder
#       translated_port     = "3389"
#     }
#   }
# }
