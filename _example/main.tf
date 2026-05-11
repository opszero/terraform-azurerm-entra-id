provider "azuread" {}

provider "azurerm" {
  features {}
}

# Auto-discover tenant domain and subscription scope.
data "azuread_client_config" "current" {}
data "azuread_domains" "default" { only_default = true }
data "azurerm_subscription" "current" {}

locals {
  tenant_domain   = data.azuread_domains.default.domains[0].domain_name
  subscription_id = data.azurerm_subscription.current.id
}

module "entra_id" {
  source = "../"

  users = {
    alice = {
      user_principal_name   = "alice@${local.tenant_domain}"
      display_name          = "Alice Smith"
      given_name            = "Alice"
      surname               = "Smith"
      job_title             = "DevOps Engineer"
      department            = "Engineering"
      usage_location        = "US"
      password              = "TempP@ssw0rd1!"
      force_password_change = true
      role_assignments = [
        {
          role_definition_name = "Contributor"
          scope                = local.subscription_id
        }
      ]
    }

    bob = {
      user_principal_name         = "bob@${local.tenant_domain}"
      display_name                = "Bob Jones"
      given_name                  = "Bob"
      surname                     = "Jones"
      job_title                   = "Security Analyst"
      department                  = "Security"
      usage_location              = "GB"
      password                    = "TempP@ssw0rd2!"
      force_password_change       = true
      disable_password_expiration = true
      role_assignments = [
        {
          role_definition_name = "Security Reader"
          scope                = local.subscription_id
        }
      ]
    }

    charlie = {
      user_principal_name   = "charlie@${local.tenant_domain}"
      display_name          = "Charlie Brown"
      given_name            = "Charlie"
      surname               = "Brown"
      job_title             = "Manager"
      department            = "Engineering"
      usage_location        = "US"
      password              = "TempP@ssw0rd3!"
      force_password_change = true
      role_assignments = [
        {
          role_definition_name = "Reader"
          scope                = local.subscription_id
        }
      ]
    }
  }
}

