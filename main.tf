locals {
  group_user_members = merge([
    for group_key, group in var.groups : {
      for member_key in group.members :
      "${group_key}:${member_key}" => {
        group_key  = group_key
        member_key = member_key
      }
    }
  ]...)

  group_external_members = merge([
    for group_key, group in var.groups : {
      for member_id in group.external_members :
      "${group_key}:${member_id}" => {
        group_key = group_key
        member_id = member_id
      }
    }
  ]...)

  active_role_display_names = toset([
    for ra in values(var.directory_role_assignments) : ra.role_display_name
  ])

  user_role_assignments = merge([
    for user_key, user in var.users : {
      for i, ra in user.role_assignments :
      "${user_key}:${i}" => {
        user_key             = user_key
        role_definition_name = ra.role_definition_name
        scope                = ra.scope
      }
    }
  ]...)

  group_role_assignments = merge([
    for group_key, group in var.groups : {
      for i, ra in group.role_assignments :
      "${group_key}:${i}" => {
        group_key            = group_key
        role_definition_name = ra.role_definition_name
        scope                = ra.scope
      }
    }
  ]...)
}

# ─── Users ─────────────────────────────────────────────────────────────────────

resource "azuread_user" "this" {
  for_each = var.users

  user_principal_name         = each.value.user_principal_name
  display_name                = each.value.display_name
  mail_nickname               = coalesce(each.value.mail_nickname, split("@", each.value.user_principal_name)[0])
  password                    = each.value.password
  force_password_change       = each.value.force_password_change
  account_enabled             = each.value.account_enabled
  given_name                  = each.value.given_name
  surname                     = each.value.surname
  job_title                   = each.value.job_title
  department                  = each.value.department
  company_name                = each.value.company_name
  office_location             = each.value.office_location
  mobile_phone                = each.value.mobile_phone
  usage_location              = each.value.usage_location
  street_address              = each.value.street_address
  city                        = each.value.city
  state                       = each.value.state
  postal_code                 = each.value.postal_code
  country                     = each.value.country
  employee_id                 = each.value.employee_id
  employee_type               = each.value.employee_type
  preferred_language          = each.value.preferred_language
  show_in_address_list        = each.value.show_in_address_list
  disable_password_expiration = each.value.disable_password_expiration
  disable_strong_password     = each.value.disable_strong_password
}

# ─── Groups ────────────────────────────────────────────────────────────────────

resource "azuread_group" "this" {
  for_each = var.groups

  display_name            = each.value.display_name
  description             = each.value.description
  security_enabled        = each.value.security_enabled
  mail_enabled            = each.value.mail_enabled
  mail_nickname           = coalesce(each.value.mail_nickname, each.key)
  types                   = each.value.types
  prevent_duplicate_names = each.value.prevent_duplicate_names

  owners = concat(
    [for owner_key in each.value.owners : azuread_user.this[owner_key].object_id],
    each.value.external_owners
  )
}

resource "azuread_group_member" "users" {
  for_each = local.group_user_members

  group_object_id  = azuread_group.this[each.value.group_key].object_id
  member_object_id = azuread_user.this[each.value.member_key].object_id
}

resource "azuread_group_member" "external" {
  for_each = local.group_external_members

  group_object_id  = azuread_group.this[each.value.group_key].object_id
  member_object_id = each.value.member_id
}

# ─── Applications ──────────────────────────────────────────────────────────────

resource "azuread_application" "this" {
  for_each = var.applications

  display_name     = each.value.display_name
  description      = each.value.description
  sign_in_audience = each.value.sign_in_audience
  identifier_uris  = each.value.identifier_uris

  dynamic "web" {
    for_each = (
      each.value.homepage_url != null ||
      each.value.logout_url != null ||
      length(each.value.redirect_uris) > 0
    ) ? [1] : []

    content {
      homepage_url  = each.value.homepage_url
      logout_url    = each.value.logout_url
      redirect_uris = each.value.redirect_uris
    }
  }
}

resource "azuread_service_principal" "this" {
  for_each = { for k, v in var.applications : k => v if v.create_service_principal }

  client_id = azuread_application.this[each.key].client_id
}

resource "azuread_application_password" "this" {
  for_each = var.application_passwords

  application_id = azuread_application.this[each.value.application_key].object_id
  display_name   = each.value.display_name
  end_date       = timeadd(plantimestamp(), each.value.end_date_relative)
}

# ─── Directory Roles ───────────────────────────────────────────────────────────

resource "azuread_directory_role" "this" {
  for_each     = local.active_role_display_names
  display_name = each.value
}

resource "azuread_directory_role_assignment" "this" {
  for_each = var.directory_role_assignments

  role_id             = azuread_directory_role.this[each.value.role_display_name].object_id
  principal_object_id = each.value.principal_object_id
}

# ─── RBAC Role Assignments ─────────────────────────────────────────────────────

resource "azurerm_role_assignment" "users" {
  for_each = local.user_role_assignments

  principal_id         = azuread_user.this[each.value.user_key].object_id
  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope
}

resource "azurerm_role_assignment" "groups" {
  for_each = local.group_role_assignments

  principal_id         = azuread_group.this[each.value.group_key].object_id
  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope
}

# ─── Guest Invitations ─────────────────────────────────────────────────────────

resource "azuread_invitation" "this" {
  for_each = var.guest_invitations

  user_email_address = each.value.email
  user_display_name  = each.value.display_name
  redirect_url       = each.value.redirect_url

  dynamic "message" {
    for_each = each.value.message != null ? [1] : []
    content {
      body = each.value.message
    }
  }
}
