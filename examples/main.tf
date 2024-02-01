module "postgres_secrets" {
  source = "./.."

  vault_mount_postgres_path = "postgres"
  database_connection_name = "my-postgres-server"

  database_addresses = "10.5.43.7"
  database_username = "postgres"
  database_name = "postgres"
  database_roles = [
    {
      name = "superuser"
      creation_statements = [
        "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT superuser TO \"{{name}}\"; GRANT ALL PRIVILEGES ON DATABASE postgres TO \"{{name}}\";"
      ]
    } 
  ]
}