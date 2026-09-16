
variable "otara_vpn_shared_key" {
  type        = string
  description = "Pre-shared key for the MIT Manukau IKEv2 S2S VPN connection."
  sensitive   = true
}


variable "mtalbert_vpn_shared_key" {
  type        = string
  description = "Pre-shared key for the Unitec IKEv2 S2S VPN connection."
  sensitive   = true
}
