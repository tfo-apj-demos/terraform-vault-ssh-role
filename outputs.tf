output "credential_path" {
  value = "${vault_ssh_secret_backend_role.this.backend}/sign/${vault_ssh_secret_backend_role.this.name}"
}

output "token" {
  value = vault_token.this.client_token
  sensitive = true
}