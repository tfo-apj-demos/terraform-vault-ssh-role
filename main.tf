locals {}

resource "vault_ssh_secret_backend_role" "this" {
  backend = var.ssh_mount_path
  name                    = "my-role"
  key_type                = "ca"
  allow_user_certificates = true
  # allowed_user_key_config {
  #   type    = "ed25519"
  #   lengths = [2048, 4096]
  # }
  default_user = "ubuntu"
  allowed_users = "*"
  ttl = "28800"
  max_ttl = "28800"
  default_extensions = {"permit-pty"=""}
}


resource "vault_policy" "this" {
  for_each = { for role in vault_database_secret_backend_role.this: role.name => role }

  name = each.value.name
  policy =<<EOH
path "${vault_ssh_secret_backend_role.this.backend}/creds/${each.value.name}" {
    capabilities = ["read"]
}
EOH 
}

resource "vault_token" "this" {
  no_parent = true
  period    = "24h"
  policies = concat([
    for policy in vault_policy.this: policy.name 
  ],[
    "revoke_lease"
  ])
  metadata = {
    "purpose" = "service-account"
  }
}