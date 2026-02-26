##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  hoop_tags = length(try(var.hoop.tags, {})) > 0 ? join(" ", [for k, v in var.hoop.tags : "--tags \"${k}=${v}\""]) : ""
  hoop_connection_owners = try(var.hoop.enabled, false) && try(var.hoop.agent, "") != "" && strcontains(local.psql.engine, "postgres") ? {
    for key, db in var.databases : key => <<EOT
hoop admin create connection ${local.psql.server_name}-${postgresql_database.this[key].name}-ow \
  --agent ${var.hoop.agent} \
  --type database/postgres \
  -e "HOST=_aws:${aws_secretsmanager_secret.owner[key].name}:host" \
  -e "PORT=_aws:${aws_secretsmanager_secret.owner[key].name}:port" \
  -e "USER=_aws:${aws_secretsmanager_secret.owner[key].name}:username" \
  -e "PASS=_aws:${aws_secretsmanager_secret.owner[key].name}:password" \
  -e "DB=_aws:${aws_secretsmanager_secret.owner[key].name}:dbname" \
  -e "SSLMODE=${try(var.hoop.default_sslmode, "require")}" \
  --overwrite ${local.hoop_tags}
EOT
    if try(db.create_owner, false)
  } : {}
  hoop_connection_users = try(var.hoop.enabled, false) && try(var.hoop.agent, "") != "" && strcontains(local.psql.engine, "postgres") ? {
    for key, role_user in var.users : key => <<EOT
hoop admin create connection ${local.psql.server_name}-${(try(role_user.db_ref, "") != "" ? postgresql_database.this[role_user.db_ref].name : role_user.database_name)}-${role_user.name} \
  --agent ${var.hoop.agent} \
  --type database/postgres \
  -e "HOST=_aws:${aws_secretsmanager_secret.user[key].name}:host" \
  -e "PORT=_aws:${aws_secretsmanager_secret.user[key].name}:port" \
  -e "USER=_aws:${aws_secretsmanager_secret.user[key].name}:username" \
  -e "PASS=_aws:${aws_secretsmanager_secret.user[key].name}:password" \
  -e "DB=_aws:${aws_secretsmanager_secret.user[key].name}:dbname" \
  -e "SSLMODE=${try(var.hoop.default_sslmode, "require")}" \
  --overwrite ${local.hoop_tags}
EOT
  } : {}
}

resource "null_resource" "hoop_connection_owners" {
  for_each = {
    for k, v in local.hoop_connection_owners : k => v
    if var.run_hoop
  }
  provisioner "local-exec" {
    command     = each.value
    interpreter = ["bash", "-c"]
  }
}

output "hoop_connection_owners" {
  value = values(local.hoop_connection_owners)
}

resource "null_resource" "hoop_connection_users" {
  for_each = {
    for k, v in local.hoop_connection_users : k => v
    if var.run_hoop
  }
  provisioner "local-exec" {
    command     = each.value
    interpreter = ["bash", "-c"]
  }
}

output "hoop_connection_users" {
  value = values(local.hoop_connection_users)
}

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