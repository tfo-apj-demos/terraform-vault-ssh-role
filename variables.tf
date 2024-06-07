variable "ssh_mount_path" {
  type = string
  default = "ssh"
}
variable "ssh_role_name" {
  type = string
}
variable "ssh_default_user" {
  type = string
  default = "ubuntu"
}
variable "ssh_allowed_users" {
  type = string
  description = "Comma separated string of permitted usernames to authenticate as."
  default = "*"
}
