# ta-alz-network

Terraform root module that deploys the platform's connectivity landing zone: resource groups for
network, ExpressRoute, VPN, Bastion, private endpoints, and private DNS (`main.tf`), the platform
and identity VNets with their subnets (`main.vnet_platform.tf`, `main.vnet_identity.tf`), NSGs for
each (`main.nsg_platform.tf`, `main.nsg_identity.tf`), the private DNS zone group
(`main.pdns_zone.tf`), and a Key Vault for connectivity secrets (`main.kv-connectivity.tf`).

This stack depends on `ta-alz-core` having applied first: `remote_state.tf` reads the `alz`
workspace's `alz_config` and `platform_log_analytics_workspace_id` outputs.

## What's actually deployed vs. commented out

A large part of this stack's `.tf` files are scaffolded but **not currently live** — entirely
commented out **temporarily, for cost savings** in the current environment. This is deliberate,
not abandoned work: these have to be uncommented and enabled for prod.

| File | Status |
|---|---|
| `main.tf` — 7 resource groups (`rg_nw_001`–`006`, `rg_identity_001`) | **Live** |
| `main.vnet_platform.tf`, `main.vnet_identity.tf` — platform & identity VNets/subnets | **Live** |
| `main.nsg_platform.tf`, `main.nsg_identity.tf` — NSGs | **Live** |
| `main.pdns_zone.tf` — private DNS zone group | **Live** (VNet links commented out) |
| `main.kv-connectivity.tf` — Key Vault for connectivity secrets | **Live** |
| `main.vwan-vhub.tf` — Virtual WAN + virtual hub | Commented out — cost savings, enable for prod |
| `main.vpn.tf` — VPN gateway, two site-to-site VPN connections (MIT Otara, Unitec Mt Albert) | Commented out — cost savings, enable for prod |
| `main.pdns_resolver.tf` — DNS Private Resolver | Commented out — cost savings, enable for prod |
| `main.bastion.tf` — Azure Bastion host | Commented out — cost savings, enable for prod |
| `main.expressroute.tf` | Empty — only `locals.expressroute.tf` parameters exist, no resource at all yet |
| `reference/main.vwan.firewall_policy.tf` | Not part of the root module (subdirectory) — a proposed firewall policy sketch, for reference only |

In short: today this stack stands up the RG/VNet/NSG/DNS-zone/KV skeleton to keep run costs down,
but the actual hub (vWAN), any inter-site connectivity (VPN/ExpressRoute), DNS resolution across
the hub, and Bastion remoting are not yet turned on. Don't assume connectivity exists between the
platform, identity, and any future spoke VNets until those modules are uncommented and applied —
see the pre-production task list below.

## Current temporary security posture — Key Vault

`locals.kv-connectivity.tf` and `main.kv-connectivity.tf` both flag this inline, but worth
surfacing here too since it's an active state, not just a comment: the connectivity Key Vault
currently has `public_network_access_enabled = true` and `network_acls.default_action = "Allow"`
— i.e. it's reachable over the public internet with no network-layer restriction (Entra
ID/RBAC auth is still required to actually read secrets, but there's no network boundary). This
is explicitly temporary, pending the vWAN/vHub peering that would let a private endpoint reach it
instead. It also currently holds the two VPN pre-shared key secrets
(`vpn_psk_otara`, `vpn_psk_mtalbert`). See the pre-production task list below.

Also note: both `vpn_psk_otara` and `vpn_psk_mtalbert` are currently set to the **same**
`random_password.temp_vpn_psk.result` value. This is intentional as a bootstrap placeholder — the
Key Vault secrets need *some* value to be created with, and `random_password` supplies that so the
vault can be deployed now, ahead of the real VPN tunnels existing. It is not meant to be the
production PSK for either tunnel.

## Pre-production task list

- [ ] **Revert the Key Vault's temporary public network access** in `main.kv-connectivity.tf`
  once vWAN/vHub peering exists and a private endpoint can reach it: set
  `public_network_access_enabled = false` and `network_acls.default_action = "Deny"` (both
  currently marked `# TEMPORARY` at the exact lines to change, in `main.kv-connectivity.tf` and
  `locals.kv-connectivity.tf`). Do this before this stack is deployed to prod — right now the
  vault holding both VPN PSK secrets is internet-reachable with no network boundary.
- [ ] When configuring each prod VPN tunnel, set a real, distinct PSK value for that tunnel's
  secret (`vpn_psk_otara` / `vpn_psk_mtalbert`) directly in Key Vault, manually, in place of the
  shared `random_password` bootstrap value — no Terraform change needed. `secrets_value_wo` is a
  write-only attribute: it isn't tracked in state, so as long as `secrets_value_wo_version`
  (`locals.kv-connectivity.tf`'s `vpn_psk_secret_version`) stays unchanged, Terraform won't push
  its bootstrap value back over the manually-set one on a later apply.
- [ ] **Uncomment and enable the cost-saving-deferred modules for prod**: `main.vwan-vhub.tf`
  (Virtual WAN + hub), `main.vpn.tf` (VPN gateway + the two site-to-site connections),
  `main.pdns_resolver.tf` (DNS Private Resolver), and `main.bastion.tf` (Bastion host). These are
  fully commented out right now purely to save cost in the current environment, not because
  they're unfinished or abandoned — prod needs actual hub connectivity, inter-site VPN, DNS
  resolution, and Bastion remoting, none of which exist while these stay commented out.

## Module versions

As of 2026-09-22, checked against the Terraform Registry:

| Module | Pinned version | Latest available (2026-09-22) | Status |
|---|---|---|---|
| `Azure/avm-res-network-virtualnetwork/azurerm` (used 3×: `platform_vnet_001`, `platform_vnet_005`, `identity_vnet_001`) | 0.22.1 | 0.22.2 | Live — one patch behind |
| `Azure/avm-res-network-networksecuritygroup/azurerm` (used 3×: `nsg_nw_001`, `nsg_nw_004_bastion`, `nsg_nw_005`, `nsg_nw_vnet_idn_001`) | 0.5.1 | 0.5.1 | Live — current |
| `Azure/avm-ptn-network-private-link-private-dns-zones/azurerm` | 0.23.2 | 0.23.2 | Live — current |
| `Azure/avm-res-keyvault-vault/azurerm` | 0.11.0 | 0.11.0 | Live — current |
| `Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm` | 0.17.1 | 0.17.2 | Commented out — one patch behind |
| `Azure/avm-res-network-bastionhost/azurerm` | 0.9.0 | 0.9.0 | Commented out — current |
| `Azure/avm-res-network-dnsresolver/azurerm` | 0.8.0 | 0.8.0 | Commented out — current |

Re-check with the Terraform Registry API before bumping any pin, e.g.:

```zsh
curl -s https://registry.terraform.io/v1/modules/Azure/avm-res-network-virtualnetwork/azurerm/versions | jq -r '.modules[0].versions[].version'
```

## Configuration

Per-resource naming and parameters live in a `locals.<area>.tf` file next to each `main.<area>.tf`
(e.g. `locals.vnet_platform.tf` for `main.vnet_platform.tf`), all built from
`local.alz_config` (read from `ta-alz-core`'s remote state) plus `locals.tf`'s `common_tags`.
Resource group / VNet / NSG names follow the repo's `<org_id>-<resource type>-<application>-
<environment>-<region short>-<instance>` convention; instance numbers `001`–`006` correspond to
platform network, ExpressRoute circuits, VPN sites/connections, Bastion, private endpoints, and
private DNS zone respectively (see the comments in `main.tf`).

No `variables.tf` or `terraform.tfvars` are used in this stack (both present but empty) — same as
`ta-alz-core`, all configuration is hardcoded into `locals.*.tf` files rather than exposed as
`var`s.

## Deploying

Same VCS-driven flow as `ta-alz-core`/`ta-alz-iam`: push to the tracked branch, review the plan in
the HCP Terraform workspace `alz-network` (org `padi-org`), approve the apply. Run this only after
`ta-alz-core` has applied successfully.

## Outputs

- `private_endpoints_subnet` — ID and resource group of the private-endpoints subnet
  (`platform_vnet_005`), for downstream stacks (e.g. `ta-alz-shared-services`) to attach private
  endpoints into.
- `rg_identity` — name of the identity resource group.
- `private_dns_zone_resource_ids` — map of private DNS zone resource IDs from
  `module.private_dns_zones`.
- Two outputs are commented out pending their resources being turned on:
  `private_dns_resolver_inbound_ip` (needs `main.pdns_resolver.tf` live) and
  `bastion_parameters` (needs `main.bastion.tf` live).
