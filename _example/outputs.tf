output "tenant_domain" {
  value = local.tenant_domain
}

output "user_object_ids" {
  value = module.entra_id.user_object_ids
}

output "user_principal_names" {
  value = module.entra_id.user_principal_names
}

output "role_assignment_ids" {
  value = module.entra_id.role_assignment_ids
}

output "app_client_secret" {
  value     = module.entra_id.application_passwords["myapp_secret"].value
  sensitive = true
}