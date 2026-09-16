terraform {
  cloud {
    organization = "padi-org"
    workspaces {
      name = "alz-network"
    }
  }
}