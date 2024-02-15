locals {
  # --- The connection string for the database can contain more than one host, so handling string creation for that case here.
  database_address = join("," , [ for address in var.database_addresses: "${address}:${var.database_port}"])
}

resource "vault_database_secret_backend_connection" "this" {
  plugin_name   = "postgresql-database-plugin"
  backend       = var.vault_mount_postgres_path
  name          = "${var.TFC_WORKSPACE_ID}-${var.database_connection_suffix}"
  allowed_roles = [
    for role in var.database_roles: "${var.TFC_WORKSPACE_ID}-${role.suffix}"
  ]
  #verify_connection = true

  data = {
		"username" = var.database_username
		"password" = var.database_password
	}

  postgresql {
    connection_url = "postgresql://{{username}}:{{password}}@${local.database_address}/${var.database_name}?sslmode=${var.database_sslmode}"
    username = var.database_username
		password = var.database_password
  }
}

resource "vault_generic_endpoint" "this" {
  path = "${var.vault_mount_postgres_path}/rotate-root/${vault_database_secret_backend_connection.this.name}"
  disable_read   = true
  disable_delete = true

  data_json      = "{}"

}

resource "vault_database_secret_backend_role" "this" {
  for_each = { for role in var.database_roles: "${var.TFC_WORKSPACE_ID}-${role.suffix}" => role }
  backend = var.vault_mount_postgres_path
  name    = "${var.TFC_WORKSPACE_ID}-${each.value.suffix}"
  db_name = vault_database_secret_backend_connection.this.name
  creation_statements = each.value.creation_statements
}

resource "vault_policy" "this" {
  for_each = { for role in vault_database_secret_backend_role.this: role.name => role }

  name = each.value.name
  policy =<<EOH
path "${each.value.backend}/creds/${each.value.name}" {
    capabilities = ["read"]
}
EOH 
}

resource "vault_token" "this" {
  for_each = { for policy in vault_policy.this: policy.name => policy }
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