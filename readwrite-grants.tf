##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

resource "postgresql_grant" "user_usage_schema" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readwrite" || try(user.grant, "") == "readonly"
  }
  database    = try(each.value.db_ref, "") != "" ? var.databases[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
  object_type = "schema"
  schema      = try(each.value.schema, "public")
  privileges  = ["USAGE"]
}

resource "postgresql_default_privileges" "user_tab_def_priv" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readwrite"
  }
  database    = try(each.value.db_ref, "") != "" ? var.databases[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
  owner       = local.admin_role[each.key].admin_role
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

resource "postgresql_grant" "user_tab_def_priv" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readwrite"
  }
  database    = try(each.value.db_ref, "") != "" ? var.databases[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
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
  database    = try(each.value.db_ref, "") != "" ? var.databases[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
  owner       = local.admin_role[each.key].admin_role
  object_type = "sequence"
  schema      = try(each.value.schema, "public")
  privileges = [
    "SELECT",
    "UPDATE",
  ]
}

resource "postgresql_grant" "user_seq_def_priv" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readwrite"
  }
  database    = try(each.value.db_ref, "") != "" ? var.databases[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
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
  database    = try(each.value.db_ref, "") != "" ? var.databases[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
  owner       = local.admin_role[each.key].admin_role
  object_type = "function"
  schema      = try(each.value.schema, "public")
  privileges = [
    "EXECUTE",
  ]
}

resource "postgresql_grant" "user_func_def_priv" {
  for_each = {
    for key, user in var.users : key => user if try(user.grant, "") == "readwrite"
  }
  database    = try(each.value.db_ref, "") != "" ? var.databases[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
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
  database    = try(each.value.db_ref, "") != "" ? var.databases[each.value.db_ref].name : each.value.database_name
  role        = postgresql_role.user[each.key].name
  owner       = local.admin_role[each.key].admin_role
  object_type = "type"
  schema      = try(each.value.schema, "public")
  privileges = [
    "USAGE",
  ]
}

