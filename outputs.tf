output "role_paths" {
  value = [ for role in vault_database_secret_backend_role.this: "${vault_database_secret_backend_role.this.backend}/creds/${vault_database_secret_backend_role.this.name}" ]
}