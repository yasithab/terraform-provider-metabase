variable "metabase_session_token" {
  type      = string
  sensitive = true
}

variable "create_metabase_user_group" {
  type    = bool
  default = true
}

variable "metabase_user_group_name" {
  type = string
}

variable "metabase_user_group_id" {
  type    = number
  default = 1
}

variable "database_engine" {
  type = string
}

variable "database_host" {
  type = string
}

variable "database_port" {
  type = number
}

variable "database_username" {
  type      = string
  sensitive = true
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "ssl_enabled" {
  type    = bool
  default = false
}

variable "ssh_tunnel_enabled" {
  type    = bool
  default = false
}

variable "advanced_options_enabled" {
  type    = bool
  default = false
}

variable "database_connection_info" {
  type = list(object({
    display_name  = string
    database_name = string
  }))
}
