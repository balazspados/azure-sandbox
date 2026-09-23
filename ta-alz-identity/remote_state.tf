### This fetches the output of alz-management TF config
data "terraform_remote_state" "alz" {
  backend = "remote"

  config = {
    organization = "padi-org"
    workspaces = {
      name = "alz"
    }
  }
}

data "terraform_remote_state" "alz_network" {
  backend = "remote"

  config = {
    organization = "padi-org"
    workspaces = {
      name = "alz-network"
    }
  }
}

data "terraform_remote_state" "alz_security" {
  backend = "remote"

  config = {
    organization = "padi-org"
    workspaces = {
      name = "alz-security"
    }
  }
}