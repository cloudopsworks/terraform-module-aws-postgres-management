##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "hoop_connection" "owners" {
  for_each = {
    for key, db in var.databases : key => db
    if try(db.create_owner, false) && try(var.hoop.enabled, false) && try(var.hoop.agent_id, "") != ""
  }
  name     = format("%s-%s-ow", local.psql.server_name, postgresql_database.this[each.key].name)
  type     = "database"
  subtype  = "postgres"
  agent_id = var.hoop.agent_id
  secrets = {
    "envvar:HOST"    = "_aws:${aws_secretsmanager_secret.owner[each.key].name}:host"
    "envvar:PORT"    = "_aws:${aws_secretsmanager_secret.owner[each.key].name}:port"
    "envvar:USER"    = "_aws:${aws_secretsmanager_secret.owner[each.key].name}:username"
    "envvar:PASS"    = "_aws:${aws_secretsmanager_secret.owner[each.key].name}:password"
    "envvar:DB"      = "_aws:${aws_secretsmanager_secret.owner[each.key].name}:dbname"
    "envvar:SSLMODE" = try(var.hoop.default_sslmode, "require")
  }
  access_mode_connect  = "enabled"
  access_mode_exec     = "enabled"
  access_mode_runbooks = "enabled"
  access_schema        = "enabled"
  tags                 = var.hoop.tags
}

resource "hoop_plugin_connection" "owner_access_control" {
  for_each = {
    for key, db in var.databases : key => db
    if try(db.create_owner, false) && try(var.hoop.enabled, false) && try(var.hoop.agent_id, "") != "" && (length(try(var.hoop.access_control, [])) > 0 || length(try(db.hoop.access_control, [])) > 0)
  }
  connection_id = hoop_connection.owners[each.key].id
  plugin_name   = "access_control"
  config        = setunion(toset(try(var.hoop.access_control, [])), toset(try(each.value.hoop.access_control, [])))
}

resource "hoop_connection" "users" {
  for_each = {
    for key, role_user in var.users : key => role_user
    if try(var.hoop.enabled, false) && try(var.hoop.agent_id, "") != ""
  }
  name = format("%s-%s-%s",
    local.psql.server_name,
    (try(each.value.db_ref, "") != "" ? postgresql_database.this[each.value.db_ref].name : each.value.database_name),
  each.value.name)
  type     = "database"
  subtype  = "postgres"
  agent_id = var.hoop.agent_id
  secrets = {
    "envvar:HOST"    = "_aws:${aws_secretsmanager_secret.user[each.key].name}:host"
    "envvar:PORT"    = "_aws:${aws_secretsmanager_secret.user[each.key].name}:port"
    "envvar:USER"    = "_aws:${aws_secretsmanager_secret.user[each.key].name}:username"
    "envvar:PASS"    = "_aws:${aws_secretsmanager_secret.user[each.key].name}:password"
    "envvar:DB"      = "_aws:${aws_secretsmanager_secret.user[each.key].name}:dbname"
    "envvar:SSLMODE" = try(var.hoop.default_sslmode, "require")
  }
  access_mode_connect  = "enabled"
  access_mode_exec     = "enabled"
  access_mode_runbooks = "enabled"
  access_schema        = "enabled"
  tags                 = var.hoop.tags
}

resource "hoop_plugin_connection" "user_access_control" {
  for_each = {
    for key, role_user in var.users : key => role_user
    if try(var.hoop.enabled, false) && try(var.hoop.agent_id, "") != "" && (length(try(var.hoop.access_control, [])) > 0 || length(try(role_user.hoop.access_control, [])) > 0)
  }
  connection_id = hoop_connection.users[each.key].id
  plugin_name   = "access_control"
  config        = setunion(toset(try(var.hoop.access_control, [])), toset(try(each.value.hoop.access_control, [])))
}
