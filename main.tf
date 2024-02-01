locals {
  # --- The connection string for the database can contain more than one host, so handling string creation for that case here.
  database_address = join("," , [ for address in var.database_addresses: "${address}:${var.database_port}"])
  connection_url = var.database_username == "" ? "postgresql://{{username}}@${local.database_address}/${var.database_name}?sslmode=${var.database_sslmode}" : "postgresql://{{username}}:{{password}}@${local.database_address}/${var.database_name}?sslmode=${var.database_sslmode}"
}

resource "vault_database_secret_backend_connection" "this" {
  plugin_name   = "postgresql-database-plugin"
  backend       = var.vault_mount_postgres_path
  name          = var.database_connection_name
  allowed_roles = [
    for role in var.database_roles: role.name
  ]
  verify_connection = true

  data = {
		"username" = var.database_username
		"password" = var.database_password
		"connection_url" = local.connection_url
	}

  postgresql {
    connection_url = local.connection_url
  }
}

resource "vault_generic_endpoint" "this" {
  path = "${var.vault_mount_postgres_path}/rotate-root/${vault_database_secret_backend_connection.this.name}"
  disable_read   = true
  disable_delete = true

  data_json      = "{}"

}

resource "vault_database_secret_backend_role" "this" {
  for_each = { for role in var.database_roles: role.name => role }
  backend = var.vault_mount_postgres_path
  name    = each.value.name
  db_name = var.database_name
  creation_statements = each.value.creation_statements
}
