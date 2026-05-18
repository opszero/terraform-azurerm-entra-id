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
## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.0.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_passwords"></a> [application\_passwords](#input\_application\_passwords) | Map of client secrets to create for application registrations. The application\_key must match a key in var.applications. | <pre>map(object({<br/>    application_key   = string<br/>    display_name      = optional(string)<br/>    end_date_relative = optional(string, "8760h")<br/>  }))</pre> | `{}` | no |
| <a name="input_applications"></a> [applications](#input\_applications) | Map of Azure AD application registrations to create. | <pre>map(object({<br/>    display_name             = string<br/>    description              = optional(string)<br/>    sign_in_audience         = optional(string, "AzureADMyOrg")<br/>    homepage_url             = optional(string)<br/>    logout_url               = optional(string)<br/>    redirect_uris            = optional(list(string), [])<br/>    identifier_uris          = optional(list(string), [])<br/>    create_service_principal = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_directory_role_assignments"></a> [directory\_role\_assignments](#input\_directory\_role\_assignments) | Map of Azure AD directory role assignments. principal\_object\_id must be the object ID of a user, group, or service principal. | <pre>map(object({<br/>    role_display_name   = string<br/>    principal_object_id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | Map of Azure AD groups to create. Keys are arbitrary identifiers used to reference groups in other variables. | <pre>map(object({<br/>    display_name            = string<br/>    description             = optional(string)<br/>    security_enabled        = optional(bool, true)<br/>    mail_enabled            = optional(bool, false)<br/>    mail_nickname           = optional(string)<br/>    types                   = optional(list(string), [])<br/>    prevent_duplicate_names = optional(bool, false)<br/>    members                 = optional(list(string), [])<br/>    external_members        = optional(list(string), [])<br/>    owners                  = optional(list(string), [])<br/>    external_owners         = optional(list(string), [])<br/>    role_assignments        = optional(list(object({<br/>      role_definition_name = string<br/>      scope                = string<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_guest_invitations"></a> [guest\_invitations](#input\_guest\_invitations) | Map of guest user invitations to send. | <pre>map(object({<br/>    email        = string<br/>    display_name = optional(string)<br/>    redirect_url = string<br/>    message      = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | Map of Azure AD users to create. Keys are arbitrary identifiers used to reference users in other variables. | <pre>map(object({<br/>    user_principal_name         = string<br/>    display_name                = string<br/>    mail_nickname               = optional(string)<br/>    password                    = optional(string)<br/>    force_password_change       = optional(bool, true)<br/>    account_enabled             = optional(bool, true)<br/>    given_name                  = optional(string)<br/>    surname                     = optional(string)<br/>    job_title                   = optional(string)<br/>    department                  = optional(string)<br/>    company_name                = optional(string)<br/>    office_location             = optional(string)<br/>    mobile_phone                = optional(string)<br/>    usage_location              = optional(string)<br/>    street_address              = optional(string)<br/>    city                        = optional(string)<br/>    state                       = optional(string)<br/>    postal_code                 = optional(string)<br/>    country                     = optional(string)<br/>    employee_id                 = optional(string)<br/>    employee_type               = optional(string)<br/>    preferred_language          = optional(string)<br/>    show_in_address_list        = optional(bool)<br/>    disable_password_expiration = optional(bool, false)<br/>    disable_strong_password     = optional(bool, false)<br/>    role_assignments            = optional(list(object({<br/>      role_definition_name = string<br/>      scope                = string<br/>    })), [])<br/>  }))</pre> | `{}` | no |
## Resources

| Name | Type |
|------|------|
| [azuread_application.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_directory_role.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role) | resource |
| [azuread_directory_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_assignment) | resource |
| [azuread_group.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_member.external](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azuread_group_member.users](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azuread_invitation.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/invitation) | resource |
| [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_user.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/user) | resource |
| [azurerm_role_assignment.groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.users](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_client_ids"></a> [application\_client\_ids](#output\_application\_client\_ids) | Map of application keys to their client (application) IDs. |
| <a name="output_application_object_ids"></a> [application\_object\_ids](#output\_application\_object\_ids) | Map of application keys to their Azure AD object IDs. |
| <a name="output_application_password_expiry"></a> [application\_password\_expiry](#output\_application\_password\_expiry) | Map of application password keys to their expiry dates. |
| <a name="output_application_password_values"></a> [application\_password\_values](#output\_application\_password\_values) | Map of application password keys to their secret values. Treat as sensitive. |
| <a name="output_application_passwords"></a> [application\_passwords](#output\_application\_passwords) | n/a |
| <a name="output_group_display_names"></a> [group\_display\_names](#output\_group\_display\_names) | Map of group keys to their display names. |
| <a name="output_group_object_ids"></a> [group\_object\_ids](#output\_group\_object\_ids) | Map of group keys to their Azure AD object IDs. |
| <a name="output_guest_invitation_redemption_urls"></a> [guest\_invitation\_redemption\_urls](#output\_guest\_invitation\_redemption\_urls) | Map of guest invitation keys to their redemption URLs. |
| <a name="output_guest_user_object_ids"></a> [guest\_user\_object\_ids](#output\_guest\_user\_object\_ids) | Map of guest invitation keys to the invited user object IDs. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map of role assignment keys to their Azure resource IDs. |
| <a name="output_service_principal_object_ids"></a> [service\_principal\_object\_ids](#output\_service\_principal\_object\_ids) | Map of application keys to their service principal object IDs. |
| <a name="output_user_mail_nicknames"></a> [user\_mail\_nicknames](#output\_user\_mail\_nicknames) | Map of user keys to their mail nicknames. |
| <a name="output_user_object_ids"></a> [user\_object\_ids](#output\_user\_object\_ids) | Map of user keys to their Azure AD object IDs. |
| <a name="output_user_principal_names"></a> [user\_principal\_names](#output\_user\_principal\_names) | Map of user keys to their user principal names. |
# 🚀 Built by opsZero!

<a href="https://opszero.com"><img src="https://opszero.com/img/common/opsZero-Logo-Large.webp" width="300px"/></a>

[opsZero](https://opszero.com) provides software and consulting for DevOps. With our decade plus of experience scaling some of the world’s most innovative companies we have developed deep expertise in Kubernetes, DevOps, FinOps, and Compliance.

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
