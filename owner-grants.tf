##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  admin_role = {
    for key, user in var.users : key => {
      name = user.name
      admin_role = try(user.db_ref, "") != "" ? (
        try(var.databases[user.db_ref].create_owner, false) ? postgresql_role.owner[user.db_ref].name :
        var.databases[user.db_ref].owner
      ) : user.database_owner
    }
  }
}

resource "postgresql_grant" "user_all_db" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "owner"
  }
  database    = try(each.value.db_ref, "") != "" ? var.databases[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
  object_type = "database"
  privileges  = ["ALL"]
}

resource "postgresql_grant" "user_all_schema" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "owner"
  }
  database    = try(each.value.db_ref, "") != "" ? var.databases[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
  object_type = "schema"
  schema      = try(each.value.schema, "public")
  privileges  = ["ALL"]
}

resource "postgresql_grant_role" "user_grant_owner" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "owner"
  }
  grant_role = local.admin_role[each.key].admin_role
  role       = postgresql_role.user[each.key].name
}

