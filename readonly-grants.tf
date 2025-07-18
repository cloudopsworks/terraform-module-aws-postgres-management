##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "postgresql_default_privileges" "user_ro_tab_def_priv" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readonly"
  }
  database    = try(each.value.db_ref, "") != "" ? postgresql_database.this[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
  owner       = local.admin_role[each.key].admin_role
  object_type = "table"
  schema      = try(each.value.schema, "public")
  privileges = [
    "SELECT",
  ]
  depends_on = [
    postgresql_database.this,
    postgresql_schema.database_schema,
  ]
}


resource "postgresql_grant" "user_ro_tab_def_priv" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readonly"
  }
  database    = try(each.value.db_ref, "") != "" ? postgresql_database.this[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
  object_type = "table"
  schema      = try(each.value.schema, "public")
  privileges = [
    "SELECT",
  ]
  depends_on = [
    postgresql_database.this,
    postgresql_schema.database_schema,
  ]
}
