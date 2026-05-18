## Usage

```hcl
module "entra_id" {
  source = "cypik/entra-id/azurerm"
  version = "1.0.0"

  users = {
    alice = {
      user_principal_name = "alice@example.onmicrosoft.com"
      display_name        = "Alice Smith"
      given_name          = "Alice"
      surname             = "Smith"
      job_title           = "DevOps Engineer"
      department          = "Engineering"
      usage_location      = "US"
      password            = "TempP@ssw0rd1!"
      force_password_change = true
    }
  }

  groups = {
    engineering = {
      display_name     = "Engineering Team"
      description      = "All engineering staff"
      security_enabled = true
      members          = ["alice"]
      owners           = ["alice"]
    }
  }

  applications = {
    my_api = {
      display_name             = "My Internal API"
      sign_in_audience         = "AzureADMyOrg"
      create_service_principal = true
      identifier_uris          = ["api://my-internal-api"]
    }
  }

  application_passwords = {
    my_api_secret = {
      application_key   = "my_api"
      display_name      = "Terraform-managed secret"
      end_date_relative = "8760h"
    }
  }

  directory_role_assignments = {
    alice_global_reader = {
      role_display_name   = "Global Reader"
      principal_object_id = "<alice-object-id>"
    }
  }

  guest_invitations = {
    vendor = {
      email        = "vendor@external.com"
      display_name = "Vendor Contact"
      redirect_url = "https://myapps.microsoft.com"
    }
  }
}
```
