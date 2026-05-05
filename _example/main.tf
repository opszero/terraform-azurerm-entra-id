provider "azuread" {}

module "entra_id" {
  source = "../"

  # ─── Users ─────────────────────────────────────────────────────────────────

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

    bob = {
      user_principal_name         = "bob@example.onmicrosoft.com"
      display_name                = "Bob Jones"
      given_name                  = "Bob"
      surname                     = "Jones"
      job_title                   = "Security Analyst"
      department                  = "Security"
      usage_location              = "GB"
      password                    = "TempP@ssw0rd2!"
      force_password_change       = true
      disable_password_expiration = true
    }

    charlie = {
      user_principal_name = "charlie@example.onmicrosoft.com"
      display_name        = "Charlie Brown"
      given_name          = "Charlie"
      surname             = "Brown"
      job_title           = "Manager"
      department          = "Engineering"
      usage_location      = "US"
      password            = "TempP@ssw0rd3!"
    }
  }

  # ─── Groups ────────────────────────────────────────────────────────────────

  groups = {
    engineering = {
      display_name     = "Engineering Team"
      description      = "All engineering staff"
      security_enabled = true
      mail_enabled     = false
      members          = ["alice", "charlie"]
      owners           = ["charlie"]
    }

    security_team = {
      display_name     = "Security Team"
      description      = "Security operations group"
      security_enabled = true
      mail_enabled     = false
      members          = ["bob"]
      owners           = ["bob"]
    }

    # Microsoft 365 group (mail-enabled, Unified type)
    all_staff = {
      display_name     = "All Staff"
      description      = "Company-wide collaboration group"
      security_enabled = true
      mail_enabled     = true
      mail_nickname    = "all-staff"
      types            = ["Unified"]
      members          = ["alice", "bob", "charlie"]
    }
  }

  # ─── Applications ──────────────────────────────────────────────────────────

  applications = {
    my_api = {
      display_name             = "My Internal API"
      description              = "Backend API service"
      sign_in_audience         = "AzureADMyOrg"
      create_service_principal = true
      identifier_uris          = ["api://my-internal-api"]
    }

    my_webapp = {
      display_name             = "My Web Application"
      description              = "Customer-facing web app"
      sign_in_audience         = "AzureADMyOrg"
      create_service_principal = true
      homepage_url             = "https://app.example.com"
      logout_url               = "https://app.example.com/logout"
      redirect_uris            = ["https://app.example.com/auth/callback"]
    }
  }

  # ─── Application Passwords (Client Secrets) ────────────────────────────────

  application_passwords = {
    my_api_secret = {
      application_key   = "my_api"
      display_name      = "Terraform-managed secret"
      end_date_relative = "8760h" # 1 year
    }
  }

  # ─── Directory Role Assignments ────────────────────────────────────────────

  # Uncomment and provide a valid object_id to assign directory roles.
  # directory_role_assignments = {
  #   alice_global_reader = {
  #     role_display_name   = "Global Reader"
  #     principal_object_id = module.entra_id.user_object_ids["alice"]
  #   }
  # }

  # ─── Guest Invitations ─────────────────────────────────────────────────────

  guest_invitations = {
    vendor_contact = {
      email        = "vendor@external-company.com"
      display_name = "Vendor Contact"
      redirect_url = "https://myapps.microsoft.com"
      message      = "You have been invited to collaborate with our team."
    }
  }
}

# ─── Outputs ───────────────────────────────────────────────────────────────────

output "user_object_ids" {
  value = module.entra_id.user_object_ids
}

output "group_object_ids" {
  value = module.entra_id.group_object_ids
}

output "application_client_ids" {
  value = module.entra_id.application_client_ids
}

output "service_principal_object_ids" {
  value = module.entra_id.service_principal_object_ids
}

output "guest_invitation_redemption_urls" {
  value = module.entra_id.guest_invitation_redemption_urls
}
