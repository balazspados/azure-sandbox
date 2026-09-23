# ta-alz-network

Terraform root module that deploys the platform's connectivity landing zone: resource groups for
network, ExpressRoute, VPN, Bastion, private endpoints, and private DNS (`main.tf`), the platform
and identity VNets with their subnets (`main.vnet_platform.tf`, `main.vnet_identity.tf`), NSGs for
each (`main.nsg_platform.tf`, `main.nsg_identity.tf`), the private DNS zone group
(`main.pdns_zone.tf`), a Key Vault for connectivity secrets (`main.kv-connectivity.tf`),
Microsoft Defender for Cloud's `CloudPosture` and `KeyVaults` plans on the connectivity
subscription (`main.defender.tf`), a Virtual WAN hub peered to the platform/identity VNets
(`main.vwan-vhub.tf`), a VPN gateway with two site-to-site connections (`main.vpn.tf`), a DNS
Private Resolver (`main.pdns_resolver.tf`), and an Azure Bastion host (`main.bastion.tf`).
ExpressRoute is the only piece not yet implemented (see What's deployed below).

This stack depends on `ta-alz-core` having applied first: `remote_state.tf` reads the `alz`
workspace's `alz_config` and `platform_log_analytics_workspace_id` outputs.

## What's deployed

| File | Status |
|---|---|
| `main.tf` — 7 resource groups (`rg_nw_001`–`006`, `rg_identity_001`) | **Live** |
| `main.vnet_platform.tf`, `main.vnet_identity.tf` — platform & identity VNets/subnets | **Live** |
| `main.nsg_platform.tf`, `main.nsg_identity.tf` — NSGs | **Live** |
| `main.pdns_zone.tf` — private DNS zone group, incl. the `platform_vnet_001` VNet link | **Live** |
| `main.kv-connectivity.tf` — Key Vault for connectivity secrets | **Live** |
| `main.defender.tf` — Microsoft Defender for Cloud (`CloudPosture`, `KeyVaults`) | **Live** |
| `main.vwan-vhub.tf` — Virtual WAN + virtual hub, peered to all 3 platform/identity VNets | **Live** |
| `main.vpn.tf` — VPN gateway, two site-to-site VPN connections (MIT Otara, Unitec Mt Albert) | **Live** |
| `main.pdns_resolver.tf` — DNS Private Resolver, tied to `platform_vnet_001` | **Live** (outbound forwarding rules still empty — see below) |
| `main.bastion.tf` — Azure Bastion host | **Live** |
| `main.expressroute.tf` | Empty — only `locals.expressroute.tf` parameters exist, no resource at all yet |

Known gaps in the now-live configuration, worth tracking (see the pre-production task list
below for the actionable version):
- All three hub VNet peerings (`platform_vnet_001`, `platform_vnet_005`, `identity_vnet_001`) are
  still `internet_security_enabled = false`, per an inline comment "needs to be revisited after
  establishing VPN/ER connection" — the VPN connections now exist, so this is ready to revisit.
- The DNS Private Resolver's outbound `forwarding_ruleset` (`main.pdns_resolver.tf`) has an empty
  `rules = {}` — per its inline comment, real forwarding rules are pending an actual on-prem DNS
  server to forward to.

## Connectivity Key Vault

`main.kv-connectivity.tf`'s `module.key_vault_connectivity` (`Azure/avm-res-keyvault-vault/azurerm`,
pinned `0.11.0`, see table above) deploys into `rg_nw_001`, via the
`azurerm.connectivity`/`azapi.connectivity` provider aliases:

- `kv_name = "${org_id}-kv-con-${environment}-${region_short}-001"` — hyphenated, following the
  repo's usual naming convention (an earlier, hyphen-free version is left commented out directly
  above it).
- `sku_name = "standard"`, `purge_protection_enabled = true` (the module default),
  `soft_delete_retention_days = 90` — the module's default/maximum.
- `enabled_for_disk_encryption = false` (the default) — `network_acls.bypass = "AzureServices"`
  is set regardless, per an inline comment noting it's mandatory once disk encryption is enabled,
  even though it isn't yet.
- `role_assignments.deployment_user_kv_admin` grants **Key Vault Administrator** to
  `data.azurerm_client_config.connectivity.object_id` — i.e. whichever identity is running this
  stack's own Terraform apply, not a fixed admin group. The two `data.azurerm_key_vault_secret`
  reads that feed `main.vpn.tf`'s PSKs (see VPN Gateway & Site-to-Site Connections above) rely on
  that same identity/role.
- `diagnostic_settings` sends to `local.platform_log_analytics_workspace_id`, same as every other
  resource in this stack.
- The two secrets (`vpn_psk_otara`, `vpn_psk_mtalbert`) and their `random_password` bootstrap
  values are covered in Key Vault secrets below.

A private endpoint (`azurerm_private_endpoint.pep_key_vault_connectivity`) is live,
resolving `module.private_dns_zones.private_dns_zone_resource_ids["azure_key_vault"]` (see
Private DNS Zone Group above) into `platform_vnet_005`'s `private_endpoints` subnet, with a
`private_service_connection` to the vault's `vault` subresource.

## Key Vault secrets

The connectivity Key Vault now has `public_network_access_enabled = false` and
`network_acls.default_action = "Deny"`. Access is via the private
endpoint documented in Connectivity Key Vault above.

The vault holds the two VPN pre-shared key secrets (`vpn_psk_otara`, `vpn_psk_mtalbert`), and
both `main.vpn.tf`'s site-to-site connections now actively read them at apply time
(`data.azurerm_key_vault_secret.vpn_psk_otara`/`vpn_psk_mtalbert`) — these tunnels are live, not
just scaffolded. Both secrets are still set to the **same** `random_password.temp_vpn_psk.result`
value: intentional as a bootstrap placeholder so the vault could be created ahead of real PSKs
being available, but now that the tunnels are actually up and using it, replacing it with real,
distinct per-tunnel values (see the pre-production task list below) is more pressing than before.

## Pre-production task list

- [ ] **Set a real, distinct PSK value for each live prod VPN tunnel**
  (`vpn_psk_otara` / `vpn_psk_mtalbert`) directly in Key Vault, manually, in place of the shared
  `random_password` bootstrap value — no Terraform change needed. `secrets_value_wo` is a
  write-only attribute: it isn't tracked in state, so as long as `secrets_value_wo_version`
  (`locals.kv-connectivity.tf`'s `vpn_psk_secret_version`) stays unchanged, Terraform won't push
  its bootstrap value back over the manually-set one on a later apply. Both tunnels are already
  live and using the shared placeholder value today.
- [ ] **Replace the placeholder `vpn_public_ip` values** in `locals.vpn.tf`
  (`otara_vpn_site_parameters`/`mtalbert_vpn_site_parameters`, currently `1.1.1.1`/`2.2.2.2`)
  with each site's real public IP — see VPN Gateway & Site-to-Site Connections above. Neither
  tunnel can actually connect until both this and the real PSK above are set.
- [ ] **Revisit `internet_security_enabled = false`** on the three hub VNet peerings
  (`main.vwan-vhub.tf`) now that the VPN connections are live — the inline comments say this was
  deferred until a VPN/ER connection existed.
- [ ] **Add real forwarding rules** to the DNS Private Resolver's outbound ruleset
  (`main.pdns_resolver.tf`'s `forwarding_ruleset.onprem.rules`, currently `{}`) once there's an
  actual on-prem DNS server to forward to.
- [ ] **Point `main.defender.tf`'s `ta-res-azure-defender` module at the production private
  registry** once one exists — `app.terraform.io/padi-org` is dev-only (see Module versions
  above).

## Module versions

As of 2026-09-23, checked against the Terraform Registry:

| Module | Registry | Pinned version | Latest available (2026-09-23) | Status |
|---|---|---|---|---|
| `Azure/avm-res-network-virtualnetwork/azurerm` (used 3×: `platform_vnet_001`, `platform_vnet_005`, `identity_vnet_001`) | Public | 0.22.2 | 0.22.2 | Live — current |
| `Azure/avm-res-network-networksecuritygroup/azurerm` (used 4×: `nsg_nw_001`, `nsg_nw_004_bastion`, `nsg_nw_005`, `nsg_nw_vnet_idn_001`) | Public | 0.5.1 | 0.5.1 | Live — current |
| `Azure/avm-ptn-network-private-link-private-dns-zones/azurerm` | Public | 0.23.2 | 0.23.2 | Live — current |
| `Azure/avm-res-keyvault-vault/azurerm` | Public | 0.11.0 | 0.11.0 | Live — current |
| `ta-res-azure-defender/azurerm` (`main.defender.tf`) | Private (`app.terraform.io/padi-org`) | 1.0.0 | 1.0.0 (only release published) | Live — current |
| `Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm` | Public | 0.17.2 | 0.17.2 | Live — current |
| `Azure/avm-res-network-bastionhost/azurerm` | Public | 0.9.0 | 0.9.0 | Live — current |
| `Azure/avm-res-network-dnsresolver/azurerm` | Public | 0.8.0 | 0.8.0 | Live — current |

**Pre-production TODO:** `app.terraform.io/padi-org` is a dev-only private registry — the
production private registry hasn't been decided yet. `ta-res-azure-defender`'s `source` in
`main.defender.tf` will need to point at that production registry before this stack is applied
to production.

## Platform & Identity VNets

Three `Azure/avm-res-network-virtualnetwork/azurerm` calls (pinned `0.22.2`, see table above), all
using only the `azapi` provider alias (the `azurerm` alias is present but commented out on every
one — `azapi` alone is sufficient for this module):

| VNet (module) | Resource group | Address space | Subnets |
|---|---|---|---|
| `platform_vnet_001` (`main.vnet_platform.tf`) | `rg_nw_001` | `10.225.4.0/24` | `dns_resolver_inbound` (`10.225.4.0/27`), `dns_resolver_outbound` (`10.225.4.32/27`), `azure_bastion` (`AzureBastionSubnet`, `10.225.4.64/27`) |
| `platform_vnet_005` (`main.vnet_platform.tf`) | `rg_nw_005` | `10.225.8.0/21` | `private_endpoints` (`10.225.8.0/21`, same as the VNet range) |
| `identity_vnet_001` (`main.vnet_identity.tf`) | `rg_identity_001` | `10.225.32.0/24` | `snet_identity` (`10.225.32.0/27`), `snet_paw` (`10.225.32.32/27`) |

Notes:
- Every subnet gets an NSG (see the naming-convention table's `nsg_*` module names above) — the
  `azure_bastion` subnet uses `nsg_nw_004_bastion`, `platform_vnet_001`'s other two subnets use
  `nsg_nw_001`, `platform_vnet_005`'s subnet uses `nsg_nw_005`, and both `identity_vnet_001`
  subnets share `nsg_nw_vnet_idn_001`.
- `platform_vnet_001`'s `dns_resolver_inbound`/`dns_resolver_outbound` subnets each carry a
  `Microsoft.Network/dnsResolvers` service delegation, for the DNS Private Resolver
  (`main.pdns_resolver.tf`) to attach its inbound/outbound endpoints into.
- `platform_vnet_005`'s `private_endpoints` subnet sets `private_endpoint_network_policies =
  "Enabled"` explicitly — per an inline comment, this is required for the subnet's NSG to actually
  apply to private-endpoint NICs.
- All three VNets are peered into the Virtual WAN hub (see Virtual WAN Hub below) via each one's
  `hub_connection_name` local, and `platform_vnet_001`/`platform_vnet_005`/`identity_vnet_001` all
  send diagnostics to the platform Log Analytics workspace (`diagnostic_settings.law`).
- Names follow `<org_id>-vnet-<nw|idn>-<environment>-<region short>-<instance>` (e.g.
  `platform_vnet_001` → `...-vnet-nw-...-001`, `identity_vnet_001` → `...-vnet-idn-...-001`);
  subnet names are literal (`snet-dns-resolver-inbound`, `AzureBastionSubnet`, etc.), not built
  from the org-wide naming convention. Some of these are literal by necessity rather than choice
  — e.g. `AzureBastionSubnet` is a fixed, Azure-mandated name (Azure Bastion refuses to deploy
  into a subnet with any other name), not a convention violation.

## NSGs

Four `Azure/avm-res-network-networksecuritygroup/azurerm` calls (pinned `0.5.1`, see table
above), one per subnet group, all sending diagnostics to the platform Log Analytics workspace:

| NSG (module) | Attached subnet(s) | Provider alias | Rules |
|---|---|---|---|
| `nsg_nw_001` (`main.nsg_platform.tf`) | `platform_vnet_001`'s `dns_resolver_inbound`/`dns_resolver_outbound` | `azurerm.connectivity` | 1: allow DNS (port 53) inbound from VirtualNetwork |
| `nsg_nw_004_bastion` (`main.nsg_platform.tf`) | `platform_vnet_001`'s `azure_bastion` | `azurerm.connectivity` | 8 rules — Microsoft's documented mandatory Azure Bastion NSG rule set (see below) |
| `nsg_nw_005` (`main.nsg_platform.tf`) | `platform_vnet_005`'s `private_endpoints` | `azurerm.connectivity` | 1: allow HTTPS (443) inbound from VirtualNetwork |
| `nsg_nw_vnet_idn_001` (`main.nsg_identity.tf`) | `identity_vnet_001`'s `snet_identity` and `snet_paw` | `azurerm.identity` | 6 rules — AD/DC access plus an explicit deny-all (see below) |

- **`nsg_nw_004_bastion`** carries exactly the inbound/outbound rules Microsoft's own
  documentation requires for an `AzureBastionSubnet` (HTTPS/GatewayManager/AzureLoadBalancer
  inbound, host-to-host 8080/5701 both ways, SSH/RDP and HTTPS/HTTP outbound) — not an ad hoc
  rule set.
- **`nsg_nw_vnet_idn_001`** allows AD/DC traffic (Kerberos, LDAP, SMB, RPC, Global Catalog, AD Web
  Services — `locals.nsg_identity.tf`'s `rule100`/`rule101`/`rule110`) from the identity subnets
  themselves plus both VPN sites' on-prem CIDRs (`otara_vpn_site_parameters`/
  `mtalbert_vpn_site_parameters.address_cidrs` — see VPN Gateway & Site-to-Site Connections
  above), inbound DNS from `platform_vnet_001`'s `dns_resolver_outbound` subnet, and RDP to the
  identity/PAW subnets from the Bastion subnet only. It ends with an explicit `Block-All-Inbound`
  deny-all at priority `4096` — redundant with Azure's implicit default deny, but made explicit
  here for auditability.
- **`nsg_nw_005`**'s single rule has a naming/description mismatch worth knowing about:
  `locals.nsg_platform.tf`'s `rule100` is named `Allow-VNet-Https-Inbound` (and does allow HTTPS
  443) but its `description` field still reads `"Allow DNS from vNet"` — a leftover, apparently
  copy-pasted from `nsg_nw_001`'s rule. Cosmetic (the `description` isn't enforced), but
  potentially confusing when reviewing the NSG in the portal.

## Private DNS Zone Group

`main.pdns_zone.tf`'s `module.private_dns_zones` (`Azure/avm-ptn-network-private-link-private-dns-zones/azurerm`,
pinned `0.23.2`, see table above) deploys into `rg_nw_006`, via only the `azapi.connectivity`
provider alias (no `azurerm` alias needed for this module). It creates the module's full set of
standard Azure private-link DNS zones and links all three VNets to them via
`virtual_network_link_default_virtual_networks` — `platform_vnet_001`, `platform_vnet_005`
(where the private-endpoints subnet lives), and `identity_vnet_001`, each with its own link name
override (`locals.pdns_zone.tf`'s `private_dns_zone_vnet_link.<vnet>_name`).

## DNS Private Resolver

`main.pdns_resolver.tf`'s `module.private_dns_resolver` (`Azure/avm-res-network-dnsresolver/azurerm`,
pinned `0.8.0`, see table above) deploys into `rg_nw_001`, tied to `platform_vnet_001` via the
`azurerm.connectivity` provider alias:

- The inbound endpoint sits in the `dns_resolver_inbound` subnet, the outbound endpoint in
  `dns_resolver_outbound` (both carry the `Microsoft.Network/dnsResolvers` delegation required
  for this — see Platform & Identity VNets above).
- The outbound endpoint's one forwarding ruleset, `onprem`, has an empty `rules = {}` — per its
  inline comment, real forwarding rules are pending an actual on-prem DNS server to forward to
  once VPN/ExpressRoute is live (see the pre-production task list above; VPN is live now, but the
  rules are still empty).
- Its diagnostic setting sends `AllMetrics` only — `Microsoft.Network/dnsResolvers` doesn't
  support resource logs at all (per Azure Monitor's supported-logs reference, it has no log
  categories, only metrics), unlike the VPN gateway's and Bastion's diagnostic settings, which
  can and do send both.

## Microsoft Defender for Cloud

`main.defender.tf`'s `module.defender_connectivity` calls
`app.terraform.io/padi-org/ta-res-azure-defender/azurerm` (pinned `1.0.0`, see table above) — the
same private-registry module used by `ta-alz-core` — applied to the **connectivity** subscription
(via the `azurerm.connectivity` provider alias):

- `CloudPosture = { tier = "Free" }` — foundational CSPM, same baseline plan as `ta-alz-core`.
- `KeyVaults = { tier = "Standard" }` — this subscription's plan list has one entry
  `ta-alz-core`'s doesn't: Defender for Key Vault, at the paid `Standard` tier rather than
  `Free`. This is the subscription that hosts the connectivity Key Vault
  (`main.kv-connectivity.tf`) holding the two VPN PSK secrets (see Key Vault secrets above) —
  Defender for Key Vault's threat detection is a sensible extra control for a vault holding
  tunnel credentials, independent of its network exposure.

See `ta-alz-core`'s README for the module's full `resource_type` key list and the rationale for
using a private-registry module instead of an AVM one (there's no published AVM module for
subscription-level Defender plans).

## Virtual WAN Hub

`main.vwan-vhub.tf`'s `module.virtual_wan_hub` (`Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm`,
pinned `0.17.2`, see table above) creates the Virtual WAN and a single virtual hub, `primary`, in
`rg_nw_001`, via the `azurerm.connectivity`/`azapi.connectivity` provider aliases:

- `virtual_wan_settings` creates the Virtual WAN resource itself (name, type,
  `allow_branch_to_branch_traffic` from `local.vwan_parameters`) plus, optionally, a DDoS
  protection plan (`enabled_resources.ddos_protection_plan`, named via
  `default_naming_convention.ddos_protection_plan_name`).
- `virtual_hubs.primary` creates the hub itself (address prefix, routing preference, SKU from
  `local.vhub_parameters`).
- The hub's own `enabled_resources` block — `firewall`, `firewall_policy`, `bastion`,
  `virtual_network_gateway_express_route`, `virtual_network_gateway_vpn`, `private_dns_zones`,
  `private_dns_resolver`, `sidecar_virtual_network` — is **entirely `false`**: none of these are
  provisioned by this module. Bastion (`main.bastion.tf`), the VPN gateway
  (`main.vpn.tf`), and the DNS Private Resolver (`main.pdns_resolver.tf`) are instead deployed as
  separate resources/modules and connected to the hub via VNet peering, not via these toggles.
- `virtual_network_connections` peers all three platform/identity VNets into the hub —
  `platform_vnet_001`, `platform_vnet_005`, `identity_vnet_001` — each currently with
  `internet_security_enabled = false` (see Known gaps above and the pre-production task list).

A diagnostic setting (`azurerm_monitor_diagnostic_setting.virtual_hub`) sends `AllMetrics` from
the hub to the platform Log Analytics workspace.

## VPN Gateway & Site-to-Site Connections

`main.vpn.tf` creates the platform VPN gateway and two site-to-site connections, all via the
`azurerm.connectivity` provider alias:

- `azurerm_vpn_gateway.platform_vpngw` (`rg_nw_001`) — `${org_id}-vpn-nw-...-001`, `scale_unit =
  "2"`, `routing_preference = "Microsoft Network"`, attached to the hub's
  `virtual_hub_resource_ids["primary"]` (see Virtual WAN Hub above).
- Two site-to-site connections in `rg_nw_003`, each an `azurerm_vpn_site` +
  `azurerm_vpn_gateway_connection` pair — both explicitly commented `### Temporary VPN
  connection` in code: **MIT Otara** (instance `100`) and **Unitec Mt Albert** (instance `101`).
  Both use IKEv2 with the same IPsec policy (DH Group 14, AES256/SHA256, PFS14,
  `sa_data_size_kb`/`sa_lifetime_sec` from `locals.vpn.tf`), provider name `REANNZ`, and a
  1024 Mbps link speed.
- Both connections' `shared_key` reads its PSK from the connectivity Key Vault
  (`data.azurerm_key_vault_secret.vpn_psk_otara`/`vpn_psk_mtalbert`) — see Current temporary
  security posture above for why that value is currently a shared placeholder.

**`locals.vpn.tf`'s `vpn_public_ip` values for both sites — `1.1.1.1` (Otara) and `2.2.2.2`
(Mt Albert) — are placeholder addresses, not the real remote-site public IPs.** These tunnels
are fully wired up in Terraform and applied, but combined with the shared placeholder PSK (see
above), neither will actually establish a working IPsec tunnel until both the real public IP and
a real, distinct PSK are set for each site.

## Azure Bastion

`main.bastion.tf`'s `module.platform_bastionhost` (`Azure/avm-res-network-bastionhost/azurerm`,
pinned `0.9.0`, see table above) deploys into `rg_nw_004`, via the `azurerm.connectivity`
provider alias:

- `sku = "Standard"`, `copy_paste_enabled = true` (the module default), `file_copy_enabled =
  false` (also the default — file copy requires the Standard SKU, which is set, but it's left
  off here anyway).
- `ip_configuration.create_public_ip = true`, so the module creates its own public IP
  (`${org_id}-pip-bastion-...-001`) rather than one being supplied externally; the Bastion host
  itself deploys into `platform_vnet_001`'s `azure_bastion` subnet (`AzureBastionSubnet` — see
  Platform & Identity VNets above).
- `scale_units` is commented out in both `main.bastion.tf` and `locals.bastion.tf`, so the
  module's own default applies (2 scale units).
- A diagnostic setting (`azurerm_monitor_diagnostic_setting.platform_bastion`) sends `allLogs`
  and `AllMetrics` to the platform Log Analytics workspace.

## Configuration

Per-resource naming and parameters live in a `locals.<area>.tf` file next to each `main.<area>.tf`
(e.g. `locals.vnet_platform.tf` for `main.vnet_platform.tf`), all built from
`local.alz_config` (read from `ta-alz-core`'s remote state) plus `locals.tf`'s `common_tags`.
Resource group / VNet / NSG names follow the repo's `<org_id>-<resource type>-<application>-
<environment>-<region short>-<instance>` convention, though the resource groups themselves omit
the `<application>` segment (e.g. `<org_id>-rg-nw-<environment>-<region short>-001` — no
application token, since a resource group here isn't scoped to a single application); instance
numbers `001`–`006` correspond to platform network, ExpressRoute circuits, VPN sites/connections,
Bastion, private endpoints, and private DNS zone respectively (see the comments in `main.tf`).

No `variables.tf` or `terraform.tfvars` are used in this stack (both present but empty) — same as
`ta-alz-core`, all configuration is hardcoded into `locals.*.tf` files rather than exposed as
`var`s.

## Deploying

Same VCS-driven flow as `ta-alz-core`/`ta-alz-iam`: push to the tracked branch, review the plan in
the HCP Terraform workspace `alz-network` (org `padi-org`), approve the apply. Run this only after
`ta-alz-core` has applied successfully.

## Outputs

- `private_dns_resolver_inbound_ip` — private IP of the DNS Private Resolver's inbound endpoint,
  for pointing a new spoke VNet's `dns_servers` at, so its VMs/private endpoints can resolve
  `privatelink.*` names.
- `private_endpoints_subnet` — ID and resource group of the private-endpoints subnet
  (`platform_vnet_005`), for downstream stacks (e.g. `ta-alz-shared-services`) to attach private
  endpoints into.
- `rg_identity` — name of the identity resource group.
- `private_dns_zone_resource_ids` — map of private DNS zone resource IDs from
  `module.private_dns_zones`.
- `bastion_parameters` — the Azure Bastion host's FQDN (`module.platform_bastionhost.dns_name`).
