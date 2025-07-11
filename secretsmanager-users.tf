##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

#############
## ALL USERS
#############
locals {
  user_names_list = {
    for k, v in var.users : k => format("%s/%s/%s/%s/%s-rds-credentials",
      local.secret_store_path,
      local.psql.engine,
      local.psql.server_name,
      replace((try(v.db_ref, "") != "" ?
        var.databases[v.db_ref].name
        : v.database_name
      ), "_", "-"),
      replace(v.name, "_", "-")
    )
  }
}
resource "aws_secretsmanager_secret" "user" {
  for_each    = var.users
  name        = local.user_names_list[each.key]
  description = "RDS User Credentials - ${each.value.name} - Grants: ${each.value.grant} - ${local.psql.engine} - ${local.psql.server_name}"
  kms_key_id  = var.secrets_kms_key_id
  tags = merge(local.all_tags, {
    "rds-username" = each.value.name
    "rds-datatabase-name" = (try(each.value.db_ref, "") != "" ?
      postgresql_database.this[each.value.db_ref].name
      : each.value.database_name
    )
    "rds-server-name" = local.psql.server_name
  })
}

resource "aws_secretsmanager_secret_version" "user" {
  for_each = {
    for k, v in var.users : k => v if var.rotation_lambda_name == ""
  }
  secret_id = aws_secretsmanager_secret.user[each.key].id
  secret_string = jsonencode(merge(
    {
      username = each.value.name
      password = random_password.user[each.key].result
      host = local.hoop_connect ? (
        try(var.hoop.cluster, false) ? data.aws_rds_cluster.hoop_db_server[0].endpoint :
        data.aws_db_instance.hoop_db_server[0].address
      ) : local.psql.host
      port = local.hoop_connect ? (
        try(var.hoop.cluster, false) ? data.aws_rds_cluster.hoop_db_server[0].port :
        data.aws_db_instance.hoop_db_server[0].port
      ) : local.psql.port
      dbname  = try(each.value.db_ref, "") != "" ? postgresql_database.this[each.value.db_ref].name : each.value.database_name
      sslmode = local.hoop_connect ? var.hoop.default_sslmode : "require"
      engine  = local.psql.engine
    },
    length(data.aws_secretsmanager_secret.db_password) > 0 ? {
      masterarn = data.aws_secretsmanager_secret.db_password[0].arn
    } : {}
    )
  )
}

data "aws_secretsmanager_secrets" "user" {
  for_each = {
    for k, v in var.users : k => v if var.rotation_lambda_name != ""
  }
  filter {
    name = "name"
    values = [
      local.user_names_list[each.key]
    ]
  }
}

data "aws_secretsmanager_secret_versions" "user_rotated" {
  for_each = {
    for k, v in var.users : k => v if var.rotation_lambda_name != "" && length(data.aws_secretsmanager_secrets.user[k].names) > 0
  }
  secret_id          = local.user_names_list[each.key]
  include_deprecated = true
}

data "aws_secretsmanager_secret_version" "user_rotated" {
  for_each = {
    for k, v in var.users : k => v if var.rotation_lambda_name != "" && length(data.aws_secretsmanager_secrets.user[k].names) > 0 && try(length(data.aws_secretsmanager_secret_versions.user_rotated[k].versions), 0) > 0
  }
  secret_id = local.user_names_list[each.key]
}

resource "aws_secretsmanager_secret_version" "user_rotated" {
  for_each = {
    for k, v in var.users : k => v if var.rotation_lambda_name != ""
  }
  secret_id = aws_secretsmanager_secret.user[each.key].id
  secret_string = jsonencode(merge(
    {
      username = each.value.name
      password = (
        try(length(data.aws_secretsmanager_secret_versions.user_rotated[each.key].versions), 0) > 0 && !var.force_reset ?
        jsondecode(data.aws_secretsmanager_secret_version.user_rotated[each.key].secret_string)["password"] :
        random_password.user_initial[each.key].result
      )
      host = local.hoop_connect ? (
        try(var.hoop.cluster, false) ? data.aws_rds_cluster.hoop_db_server[0].endpoint :
        data.aws_db_instance.hoop_db_server[0].address
      ) : local.psql.host
      port = local.hoop_connect ? (
        try(var.hoop.cluster, false) ? data.aws_rds_cluster.hoop_db_server[0].port :
        data.aws_db_instance.hoop_db_server[0].port
      ) : local.psql.port
      dbname  = try(each.value.db_ref, "") != "" ? postgresql_database.this[each.value.db_ref].name : each.value.database_name
      sslmode = local.hoop_connect ? var.hoop.default_sslmode : "require"
      engine  = local.psql.engine
    },
    length(data.aws_secretsmanager_secret.db_password) > 0 ? {
      masterarn = data.aws_secretsmanager_secret.db_password[0].arn
    } : {}
    )
  )
  lifecycle {
    ignore_changes = [
      secret_string,

    ]
  }
}

resource "aws_secretsmanager_secret_rotation" "user" {
  for_each = {
    for k, v in var.users : k => v if var.rotation_lambda_name != ""
  }
  secret_id           = aws_secretsmanager_secret.user[each.key].arn
  rotation_lambda_arn = data.aws_lambda_function.rotation_function[0].arn
  rotate_immediately  = var.rotate_immediately
  rotation_rules {
    automatically_after_days = var.password_rotation_period
    duration                 = var.rotation_duration
  }
  depends_on = [
    aws_secretsmanager_secret_version.user_rotated
  ]
}
