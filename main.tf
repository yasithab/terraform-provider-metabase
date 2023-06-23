##############################################################
# Locals
##############################################################

locals {
  # Metabase User group id
  group_id = var.create_metabase_user_group ? restapi_object.create_permission_group[0].id : var.metabase_user_group_id

  # Current permission mappings
  current_permissions = jsondecode(restapi_object.read_permissions_graph.create_response)

  # Additional permission mappings
  additional_permissions = tomap({
    groups = {
      (local.group_id) = {
        for info in var.database_connection_info : restapi_object.create_data_source[info.database_name].api_data.id => {
          data = {
            native  = "write"
            schemas = "all"
          }
        }
      }
    }
  })

  # Merged permission mappings
  merged_permissions = {
    "revision" = local.current_permissions.revision
    "groups"   = merge(local.current_permissions.groups, local.additional_permissions.groups)
  }
}

##############################################################
# Create a metabase user group
##############################################################

resource "restapi_object" "create_permission_group" {
  count         = var.create_metabase_user_group ? 1 : 0
  id_attribute  = "id"
  path          = "/permissions/group"
  create_method = "POST"
  data = jsonencode({
    name = var.metabase_user_group_name
  })
}

##############################################################
# Create metabase data source
##############################################################

resource "restapi_object" "create_data_source" {
  for_each = { for info in var.database_connection_info : info.database_name => info }

  path          = "/database"
  create_method = "POST"
  data = jsonencode({
    name   = each.value.display_name
    engine = var.database_engine
    details = {
      dbname           = each.value.database_name
      host             = var.database_host
      port             = var.database_port
      user             = var.database_username
      password         = var.database_password
      ssl              = var.ssl_enabled
      tunnel-enabled   = var.ssh_tunnel_enabled
      advanced-options = var.advanced_options_enabled
    }
  })
}

##############################################################
# Read the current permission mappings
##############################################################

resource "restapi_object" "read_permissions_graph" {
  id_attribute  = "revision"
  path          = "/permissions/graph"
  create_method = "GET"
  data = jsonencode({
    Accept             = "application/json"
    X-Metabase-Session = var.metabase_session_token
  })
}

##############################################################
# Update permission mappings
##############################################################

resource "restapi_object" "update_permissions_graph" {
  id_attribute   = "revision"
  path           = "/permissions/graph"
  create_method  = "PUT"
  destroy_method = "GET"
  data           = jsonencode(local.merged_permissions)
}

##############################################################
