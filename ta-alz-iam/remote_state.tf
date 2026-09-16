
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