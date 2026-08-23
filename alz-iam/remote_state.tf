
#This fetches the output of alz-management TF config
data "terraform_remote_state" "alz-management" {
  backend = "remote"

  config = {
    organization = "padi-org"
    workspaces = {
      name = "alz-management"
    }
  }
}

#This fetches the output of alz TF config
data "terraform_remote_state" "alz" {
  backend = "remote"

  config = {
    organization = "padi-org"
    workspaces = {
      name = "alz"
    }
  }
}