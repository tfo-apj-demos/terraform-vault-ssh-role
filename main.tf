locals {}

resource "vault_ssh_secret_backend_role" "this" {
  backend = var.ssh_mount_path
  name                    = var.ssh_role_name
  key_type                = "ca"
  allow_user_certificates = true
  # allowed_user_key_config {
  #   type    = "ed25519"
  #   lengths = [2048, 4096]
  # }
  default_user = var.ssh_default_user #"ubuntu"
  allowed_users = var.ssh_allowed_users #"*"
  ttl = "28800"
  max_ttl = "28800"
  default_extensions = {"permit-pty"=""}
}


resource "vault_policy" "this" {
  name = vault_ssh_secret_backend_role.this.name
  policy =<<EOH
path "${vault_ssh_secret_backend_role.this.backend}/sign/${vault_ssh_secret_backend_role.this.name}" {
    capabilities = ["update"]
}
EOH 
}

resource "vault_token" "this" {
  no_parent = true
  period    = "24h"
  policies = concat([
    vault_policy.this.name,
    "revoke_lease"
  ])
  metadata = {
    "purpose" = "service-account"
  }
}