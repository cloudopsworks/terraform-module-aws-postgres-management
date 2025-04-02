##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

resource "postgresql_grant" "user_connect" {
  for_each    = var.users
  database    = try(each.value.db_ref, "") != "" ? var.databases[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
  object_type = "database"
  privileges  = ["CONNECT"]
}
