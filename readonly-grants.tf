##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

resource "postgresql_default_privileges" "user_ro_tab_def_priv" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readonly"
  }
  database    = try(var.databases[each.value.db_ref].name, try(each.value.database_name, null))
  role        = postgresql_role.user[each.key].name
  owner       = "DEFAULT"
  object_type = "table"
  schema      = try(each.value.schema, "public")
  privileges = [
    "SELECT",
  ]
}
