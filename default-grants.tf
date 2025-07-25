##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "postgresql_grant" "user_connect" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") != "owner"
  }
  depends_on  = [postgresql_database.this]
  database    = try(each.value.db_ref, "") != "" ? postgresql_database.this[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
  object_type = "database"
  privileges  = ["CONNECT"]
}
