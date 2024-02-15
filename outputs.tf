output "role_paths" {
  value = [ for role in vault_database_secret_backend_role.this: "${role.backend}/creds/${role.name}" ]
}