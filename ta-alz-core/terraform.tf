terraform {
  required_version = ">= 1.15.8, <2.0.0"

  required_providers {
    alz = {
      source  = "azure/alz"
      version = "~> 0.22" # https://github.com/Azure/terraform-provider-alz
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.12" # https://github.com/Azure/terraform-provider-azapi
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81" # https://github.com/hashicorp/terraform-provider-azurerm
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7" # https://github.com/hashicorp/terraform-provider-random
    }
  }
}

# Include the additional policies and override archetypes
provider "alz" {
  library_overwrite_enabled = true
  library_references = [
    { path = "platform/alz"
      ref  = "2026.08.0" # check registry for current ref https://github.com/Azure/Azure-Landing-Zones-Library/releases
    },
    # Not in use currently
    # {
    #   "path" : "platform/amba",
    #   "ref" : "2026.06.2" # https://github.com/Azure/Azure-Landing-Zones-Library/releases#release-platform/amba/
    # },
    {
      custom_url = "${path.root}/lib"
    }
  ]
  suppress_warning_policy_role_assignments = true
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azurerm" {
  alias = "management"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = local.alz_config.management_subscription_id
}

provider "azapi" {
  alias           = "management"
  subscription_id = local.alz_config.management_subscription_id
}

provider "azurerm" {
  alias = "connectivity"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = local.alz_config.connectivity_subscription_id
}

provider "azapi" {
  alias           = "connectivity"
  subscription_id = local.alz_config.connectivity_subscription_id
}

provider "azurerm" {
  alias = "identity"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = local.alz_config.identity_subscription_id
}

provider "azurerm" {
  alias = "security"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = local.alz_config.security_subscription_id
}

provider "azapi" {
  alias           = "security"
  subscription_id = local.alz_config.security_subscription_id
}

