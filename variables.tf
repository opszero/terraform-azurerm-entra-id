variable "users" {
  description = "Map of Azure AD users to create. Keys are arbitrary identifiers used to reference users in other variables."
  type = map(object({
    user_principal_name         = string
    display_name                = string
    mail_nickname               = optional(string)
    password                    = optional(string)
    force_password_change       = optional(bool, true)
    account_enabled             = optional(bool, true)
    given_name                  = optional(string)
    surname                     = optional(string)
    job_title                   = optional(string)
    department                  = optional(string)
    company_name                = optional(string)
    office_location             = optional(string)
    mobile_phone                = optional(string)
    usage_location              = optional(string)
    street_address              = optional(string)
    city                        = optional(string)
    state                       = optional(string)
    postal_code                 = optional(string)
    country                     = optional(string)
    employee_id                 = optional(string)
    employee_type               = optional(string)
    preferred_language          = optional(string)
    show_in_address_list        = optional(bool)
    disable_password_expiration = optional(bool, false)
    disable_strong_password     = optional(bool, false)
    role_assignments            = optional(list(object({
      role_definition_name = string
      scope                = string
    })), [])
  }))
  default = {}
}

variable "groups" {
  description = "Map of Azure AD groups to create. Keys are arbitrary identifiers used to reference groups in other variables."
  type = map(object({
    display_name            = string
    description             = optional(string)
    security_enabled        = optional(bool, true)
    mail_enabled            = optional(bool, false)
    mail_nickname           = optional(string)
    types                   = optional(list(string), [])
    prevent_duplicate_names = optional(bool, false)
    members                 = optional(list(string), [])
    external_members        = optional(list(string), [])
    owners                  = optional(list(string), [])
    external_owners         = optional(list(string), [])
    role_assignments        = optional(list(object({
      role_definition_name = string
      scope                = string
    })), [])
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for k, g in var.groups :
      g.mail_enabled ? g.mail_nickname != null : true
    ])
    error_message = "Mail-enabled groups should have a mail_nickname set."
  }
}

variable "applications" {
  description = "Map of Azure AD application registrations to create."
  type = map(object({
    display_name             = string
    description              = optional(string)
    sign_in_audience         = optional(string, "AzureADMyOrg")
    homepage_url             = optional(string)
    logout_url               = optional(string)
    redirect_uris            = optional(list(string), [])
    identifier_uris          = optional(list(string), [])
    create_service_principal = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, a in var.applications :
      contains(["AzureADMyOrg", "AzureADMultipleOrgs", "AzureADandPersonalMicrosoftAccount", "PersonalMicrosoftAccount"], a.sign_in_audience)
    ])
    error_message = "sign_in_audience must be one of: AzureADMyOrg, AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount, PersonalMicrosoftAccount."
  }
}

variable "application_passwords" {
  description = "Map of client secrets to create for application registrations. The application_key must match a key in var.applications."
  type = map(object({
    application_key   = string
    display_name      = optional(string)
    end_date_relative = optional(string, "8760h")
  }))
  default   = {}
  sensitive = false
}

variable "directory_role_assignments" {
  description = "Map of Azure AD directory role assignments. principal_object_id must be the object ID of a user, group, or service principal."
  type = map(object({
    role_display_name   = string
    principal_object_id = string
  }))
  default = {}
}

variable "guest_invitations" {
  description = "Map of guest user invitations to send."
  type = map(object({
    email        = string
    display_name = optional(string)
    redirect_url = string
    message      = optional(string)
  }))
  default = {}
}
