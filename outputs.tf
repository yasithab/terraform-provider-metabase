output "user_group_id" {
  description = "The ID of the metabase permissions group"
  value       = local.group_id
}

output "database_id" {
  description = "The ID of the database"
  value = {
    for info in var.database_connection_info :
    info.database_name => restapi_object.create_data_source[info.database_name].api_data.id
  }
}
