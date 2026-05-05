# terraform-azurerm-entra-id

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.3.0-623CE4?logo=terraform)](https://www.terraform.io)
[![Azure AD Provider](https://img.shields.io/badge/azuread-%3E%3D2.53.0-0078D4?logo=microsoftazure)](https://registry.terraform.io/providers/hashicorp/azuread/latest)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

A Terraform module for managing **Microsoft Entra ID** (formerly Azure Active Directory) identities and access — users, groups, application registrations, service principals, directory role assignments, and guest invitations.

---

## Features

| Feature | Resource |
|---|---|
| User management | `azuread_user` |
| Group management | `azuread_group` |
| Group memberships (module users or external) | `azuread_group_member` |
| Application registrations | `azuread_application` |
| Service principals | `azuread_service_principal` |
| Application client secrets | `azuread_application_password` |
| Directory role activation & assignment | `azuread_directory_role`, `azuread_directory_role_assignment` |
| Guest user invitations | `azuread_invitation` |

---

## Prerequisites

- Terraform `>= 1.3.0`
- [AzureAD provider](https://registry.terraform.io/providers/hashicorp/azuread/latest) `>= 2.53.0`
- A service principal or user account with one of the following Entra ID roles:
  - **User Administrator** — to create and manage users and groups
  - **Application Administrator** — to manage app registrations and service principals
  - **Privileged Role Administrator** — to assign directory roles

---

## Authentication

Configure the AzureAD provider in your root module. The provider supports several authentication methods:

```hcl
# Option 1 — Service Principal with client secret
provider "azuread" {
  tenant_id     = var.tenant_id
  client_id     = var.client_id
  client_secret = var.client_secret
}

# Option 2 — Service Principal with client certificate
provider "azuread" {
  tenant_id            = var.tenant_id
  client_id            = var.client_id
  client_certificate   = filebase64("cert.pfx")
  client_certificate_password = var.cert_password
}

# Option 3 — Azure CLI (for local development)
provider "azuread" {}
```

---

## Module Structure

```
terraform-azurerm-entra-id/
├── main.tf          # Users, groups, applications, roles, invitations
├── variables.tf     # Input variable definitions
├── outputs.tf       # Module outputs
├── versions.tf      # Provider and Terraform version constraints
└── _example/
    └── main.tf      # Full working example
```

---

<!-- BEGIN_TF_DOCS -->
## Usage

```hcl
module "entra_id" {
  source  = "cypik/entra-id/azurerm"
  version = "1.0.0"

  # ── Users ──────────────────────────────────────────────────────────────────
  users = {
    alice = {
      user_principal_name   = "alice@example.onmicrosoft.com"
      display_name          = "Alice Smith"
      given_name            = "Alice"
      surname               = "Smith"
      job_title             = "DevOps Engineer"
      department            = "Engineering"
      usage_location        = "US"
      password              = "TempP@ssw0rd1!"
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
      disable_password_expiration = true
    }
  }

  # ── Groups ─────────────────────────────────────────────────────────────────
  groups = {
    engineering = {
      display_name     = "Engineering Team"
      description      = "All engineering staff"
      security_enabled = true
      members          = ["alice"]
      owners           = ["alice"]
    }

    # Microsoft 365 group (mail-enabled)
    all_staff = {
      display_name     = "All Staff"
      security_enabled = true
      mail_enabled     = true
      mail_nickname    = "all-staff"
      types            = ["Unified"]
      members          = ["alice", "bob"]
    }
  }

  # ── Applications ───────────────────────────────────────────────────────────
  applications = {
    my_api = {
      display_name             = "My Internal API"
      sign_in_audience         = "AzureADMyOrg"
      create_service_principal = true
      identifier_uris          = ["api://my-internal-api"]
    }

    my_webapp = {
      display_name             = "My Web Application"
      sign_in_audience         = "AzureADMyOrg"
      create_service_principal = true
      homepage_url             = "https://app.example.com"
      logout_url               = "https://app.example.com/logout"
      redirect_uris            = ["https://app.example.com/auth/callback"]
    }
  }

  # ── Application Client Secrets ─────────────────────────────────────────────
  application_passwords = {
    api_secret = {
      application_key   = "my_api"
      display_name      = "Terraform-managed secret"
      end_date_relative = "8760h"   # 1 year
    }
  }

  # ── Directory Role Assignments ─────────────────────────────────────────────
  directory_role_assignments = {
    alice_global_reader = {
      role_display_name   = "Global Reader"
      principal_object_id = "<alice-object-id>"
    }
  }

  # ── Guest Invitations ──────────────────────────────────────────────────────
  guest_invitations = {
    vendor = {
      email        = "vendor@partner.com"
      display_name = "Vendor Contact"
      redirect_url = "https://myapps.microsoft.com"
      message      = "You have been invited to collaborate with our team."
    }
  }
}
```

## Providers

| Name | Version |
|------|---------|
| [azuread](https://registry.terraform.io/providers/hashicorp/azuread/latest) | >= 2.53.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `users` | Map of Azure AD users to create. Keys are arbitrary identifiers used to reference users in groups/roles. | `map(object)` | `{}` | no |
| `groups` | Map of Azure AD groups to create. Supports security groups and Microsoft 365 groups. | `map(object)` | `{}` | no |
| `applications` | Map of Azure AD application registrations to create. | `map(object)` | `{}` | no |
| `application_passwords` | Map of client secrets to create for app registrations. | `map(object)` | `{}` | no |
| `directory_role_assignments` | Map of directory role assignments for users, groups, or service principals. | `map(object)` | `{}` | no |
| `guest_invitations` | Map of guest user invitations to send. | `map(object)` | `{}` | no |

## Resources

| Name | Type |
|------|------|
| `azuread_user.this` | resource |
| `azuread_group.this` | resource |
| `azuread_group_member.users` | resource |
| `azuread_group_member.external` | resource |
| `azuread_application.this` | resource |
| `azuread_service_principal.this` | resource |
| `azuread_application_password.this` | resource |
| `azuread_directory_role.this` | resource |
| `azuread_directory_role_assignment.this` | resource |
| `azuread_invitation.this` | resource |

## Outputs

| Name | Description |
|------|-------------|
| `user_object_ids` | Map of user keys to their Azure AD object IDs. |
| `user_principal_names` | Map of user keys to their user principal names. |
| `user_mail_nicknames` | Map of user keys to their mail nicknames. |
| `group_object_ids` | Map of group keys to their Azure AD object IDs. |
| `group_display_names` | Map of group keys to their display names. |
| `application_object_ids` | Map of application keys to their Azure AD object IDs. |
| `application_client_ids` | Map of application keys to their client (application) IDs. |
| `service_principal_object_ids` | Map of application keys to their service principal object IDs. |
| `application_password_values` | Map of password keys to secret values. **Sensitive.** |
| `application_password_expiry` | Map of password keys to their expiry dates. |
| `guest_invitation_redemption_urls` | Map of invitation keys to redemption URLs. |
| `guest_user_object_ids` | Map of invitation keys to invited user object IDs. |

<!-- END_TF_DOCS -->

---

## Variable Reference

### `users`

Each entry in the `users` map accepts the following attributes:

| Attribute | Type | Required | Default | Description |
|---|---|---|---|---|
| `user_principal_name` | `string` | yes | — | The UPN for the user (e.g. `alice@example.com`) |
| `display_name` | `string` | yes | — | Full display name |
| `password` | `string` | no | `null` | Initial password. Required for new cloud-only accounts |
| `force_password_change` | `bool` | no | `true` | Require password change on first sign-in |
| `account_enabled` | `bool` | no | `true` | Whether the account is enabled |
| `mail_nickname` | `string` | no | UPN prefix | Mail alias |
| `given_name` | `string` | no | `null` | First name |
| `surname` | `string` | no | `null` | Last name |
| `job_title` | `string` | no | `null` | Job title |
| `department` | `string` | no | `null` | Department |
| `company_name` | `string` | no | `null` | Company name |
| `usage_location` | `string` | no | `null` | Two-letter ISO country code — required for license assignment |
| `disable_password_expiration` | `bool` | no | `false` | Disable password expiry policy for this user |
| `disable_strong_password` | `bool` | no | `false` | Allow weak passwords (not recommended) |

### `groups`

| Attribute | Type | Required | Default | Description |
|---|---|---|---|---|
| `display_name` | `string` | yes | — | Display name of the group |
| `description` | `string` | no | `null` | Description |
| `security_enabled` | `bool` | no | `true` | Enable security features |
| `mail_enabled` | `bool` | no | `false` | Enable mail (required for M365 groups) |
| `mail_nickname` | `string` | no | group key | Mail alias (required for mail-enabled groups) |
| `types` | `list(string)` | no | `[]` | Group types — use `["Unified"]` for M365 groups |
| `members` | `list(string)` | no | `[]` | Keys from `var.users` to add as members |
| `external_members` | `list(string)` | no | `[]` | Raw object IDs of external principals to add as members |
| `owners` | `list(string)` | no | `[]` | Keys from `var.users` to assign as owners |
| `external_owners` | `list(string)` | no | `[]` | Raw object IDs of external owners |

### `applications`

| Attribute | Type | Required | Default | Description |
|---|---|---|---|---|
| `display_name` | `string` | yes | — | Display name of the app registration |
| `sign_in_audience` | `string` | no | `"AzureADMyOrg"` | Sign-in audience. One of `AzureADMyOrg`, `AzureADMultipleOrgs`, `AzureADandPersonalMicrosoftAccount`, `PersonalMicrosoftAccount` |
| `create_service_principal` | `bool` | no | `false` | Create a service principal for this app |
| `identifier_uris` | `list(string)` | no | `[]` | Application ID URIs |
| `homepage_url` | `string` | no | `null` | Home page URL |
| `logout_url` | `string` | no | `null` | Front-channel logout URL |
| `redirect_uris` | `list(string)` | no | `[]` | OAuth redirect URIs |

---

## Security Considerations

- **Passwords** are stored in Terraform state. Use a remote backend with encryption (e.g. Azure Storage with CMK or Terraform Cloud).
- **Application passwords** (client secrets) are marked `sensitive = true` in outputs. Rotate them using `end_date_relative` and Terraform.
- **Directory roles** like `Global Administrator` are highly privileged. Assign only what is necessary.
- Use `disable_strong_password = false` (the default) to enforce strong password policies.

---

## License

Apache 2.0 — see [LICENSE](LICENSE).

---

# 🚀 Built by opsZero!

<a href="https://opszero.com"><img src="https://opszero.com/img/common/opsZero-Logo-Large.webp" width="300px"/></a>

[opsZero](https://opszero.com) provides software and consulting for Cloud + AI. With our decade plus of experience scaling some of the world's most innovative companies we have developed deep expertise in Kubernetes, DevOps, FinOps, and Compliance.

Our software and consulting solutions enable organizations to:

- migrate workloads to the Cloud
- setup compliance frameworks including SOC2, HIPAA, PCI-DSS, ITAR, FedRamp, CMMC, and more.
- FinOps solutions to reduce the cost of running Cloud workloads
- Kubernetes optimized for web scale and AI workloads
- finding underutilized Cloud resources
- setting up custom AI training and delivery
- building data integrations and scrapers
- modernizing onto modern ARM based processors

We do this with a high-touch support model where you:

- Get access to us on Slack, Microsoft Teams or Email
- Get 24/7 coverage of your infrastructure
- Get an accelerated migration to Kubernetes

Please [schedule a call](https://calendly.com/opszero-llc/discovery) if you need support.

<br/><br/>

<div style="display: block">
  <img src="https://opszero.com/img/common/aws-advanced.png" alt="AWS Advanced Tier" width="150px" >
  <img src="https://opszero.com/img/common/aws-devops-competency.png" alt="AWS DevOps Competency" width="150px" >
  <img src="https://opszero.com/img/common/aws-eks.png" alt="AWS EKS Delivery" width="150px" >
  <img src="https://opszero.com/img/common/aws-public-sector.png" alt="AWS Public Sector" width="150px" >
</div>
