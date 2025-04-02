##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

resource "postgresql_grant" "user_usage_schema" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readwrite" || try(user.grant, "") == "readonly"
  }
  database    = try(var.databases[each.value.db_ref].name, try(each.value.database_name, null))
  role        = postgresql_role.user[each.key].name
  object_type = "schema"
  schema      = try(each.value.schema, "public")
  privileges  = ["USAGE"]
}

resource "postgresql_default_privileges" "user_tab_def_priv" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readwrite"
  }
  database    = try(var.databases[each.value.db_ref].name, try(each.value.database_name, null))
  role        = postgresql_role.user[each.key].name
  owner       = "DEFAULT"
  object_type = "table"
  schema      = try(each.value.schema, "public")
  privileges = [
    "SELECT",
    "INSERT",
    "UPDATE",
    "DELETE",
    "TRUNCATE",
    "TRIGGER",
  ]
}

resource "postgresql_default_privileges" "user_seq_def_priv" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readwrite"
  }
  database    = try(var.databases[each.value.db_ref].name, try(each.value.database_name, null))
  role        = postgresql_role.user[each.key].name
  owner       = "DEFAULT"
  object_type = "sequence"
  schema      = try(each.value.schema, "public")
  privileges = [
    "SELECT",
    "UPDATE",
  ]
}

resource "postgresql_default_privileges" "user_func_def_priv" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readwrite"
  }
  database    = try(var.databases[each.value.db_ref].name, try(each.value.database_name, null))
  role        = postgresql_role.user[each.key].name
  owner       = "DEFAULT"
  object_type = "function"
  schema      = try(each.value.schema, "public")
  privileges = [
    "EXECUTE",
  ]
}

resource "postgresql_default_privileges" "user_types_def_priv" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readwrite"
  }
  database    = try(var.databases[each.value.db_ref].name, try(each.value.database_name, null))
  role        = postgresql_role.user[each.key].name
  owner       = "DEFAULT"
  object_type = "type"
  schema      = try(each.value.schema, "public")
  privileges = [
    "USAGE",
  ]
}

