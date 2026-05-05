output "user_object_ids" {
  description = "Map of user keys to their Azure AD object IDs."
  value       = { for k, v in azuread_user.this : k => v.object_id }
}

output "user_principal_names" {
  description = "Map of user keys to their user principal names."
  value       = { for k, v in azuread_user.this : k => v.user_principal_name }
}

output "user_mail_nicknames" {
  description = "Map of user keys to their mail nicknames."
  value       = { for k, v in azuread_user.this : k => v.mail_nickname }
}

output "group_object_ids" {
  description = "Map of group keys to their Azure AD object IDs."
  value       = { for k, v in azuread_group.this : k => v.object_id }
}

output "group_display_names" {
  description = "Map of group keys to their display names."
  value       = { for k, v in azuread_group.this : k => v.display_name }
}

output "application_object_ids" {
  description = "Map of application keys to their Azure AD object IDs."
  value       = { for k, v in azuread_application.this : k => v.object_id }
}

output "application_client_ids" {
  description = "Map of application keys to their client (application) IDs."
  value       = { for k, v in azuread_application.this : k => v.application_id }
}

output "service_principal_object_ids" {
  description = "Map of application keys to their service principal object IDs."
  value       = { for k, v in azuread_service_principal.this : k => v.object_id }
}

output "application_password_values" {
  description = "Map of application password keys to their secret values. Treat as sensitive."
  value       = { for k, v in azuread_application_password.this : k => v.value }
  sensitive   = true
}

output "application_password_expiry" {
  description = "Map of application password keys to their expiry dates."
  value       = { for k, v in azuread_application_password.this : k => v.end_date }
}

output "guest_invitation_redemption_urls" {
  description = "Map of guest invitation keys to their redemption URLs."
  value       = { for k, v in azuread_invitation.this : k => v.redemption_url }
}

output "guest_user_object_ids" {
  description = "Map of guest invitation keys to the invited user object IDs."
  value       = { for k, v in azuread_invitation.this : k => v.user_id }
}
