##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

resource "postgresql_grant" "user_all_db" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "owner"
  }
  database    = try(var.databases[each.value.db_ref].name, try(each.value.database_name, null))
  role        = postgresql_role.user[each.key].name
  object_type = "database"
  privileges  = ["ALL"]
}

resource "postgresql_grant" "user_all_schema" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "owner"
  }
  database    = try(var.databases[each.value.db_ref].name, try(each.value.database_name, null))
  role        = postgresql_role.user[each.key].name
  object_type = "schema"
  schema      = try(each.value.schema, "public")
  privileges  = ["ALL"]
}

