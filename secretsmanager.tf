##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

# # Secrets saving
# resource "aws_secretsmanager_secret" "sample" {
#   name = "${local.secret_store_path}/sample/password"
#   tags = local.all_tags
# }

## DB OWNER
resource "aws_secretsmanager_secret" "owner" {
  for_each = {
    for key, db in var.databases : key => db if try(db.create_owner, false)
  }
  name = format("%s/%s/%s/%s/%s-rds-credentials",
    local.secret_store_path,
    local.psql.engine,
    local.psql.server_name,
    replace(postgresql_database.this[each.key].name, "_", "-"),
    replace(postgresql_role.owner[each.key].name, "_", "-")
  )
  description = "RDS Owner credentials - ${postgresql_role.owner[each.key].name} - ${local.psql.engine} - ${local.psql.server_name} - ${postgresql_database.this[each.key].name}"
  tags = merge(local.all_tags, {
    "rds-username"        = postgresql_role.owner[each.key].name
    "rds-datatabase-name" = postgresql_database.this[each.key].name
    "rds-server-name"     = local.psql.server_name
  })
}

resource "aws_secretsmanager_secret_version" "owner" {
  for_each = {
    for key, db in var.databases : key => db if try(db.create_owner, false)
  }
  secret_id = aws_secretsmanager_secret.owner[each.key].id
  secret_string = jsonencode({
    username = postgresql_role.owner[each.key].name
    password = random_password.owner[each.key].result
    host = local.hoop_connect ? (
      try(var.hoop.cluster, false) ? data.aws_rds_cluster.hoop_db_server[0].endpoint :
      data.aws_db_instance.hoop_db_server[0].endpoint
    ) : local.psql.host
    port = local.hoop_connect ? (
      try(var.hoop.cluster, false) ? data.aws_rds_cluster.hoop_db_server[0].port :
      data.aws_db_instance.hoop_db_server[0].port
    ) : local.psql.port
    db_name = postgresql_database.this[each.key].name
    sslmode = local.hoop_connect ? var.hoop.default_sslmode : local.psql.sslmode
    engine  = local.psql.engine
  })
}

## ALL USERS
resource "aws_secretsmanager_secret" "user" {
  for_each = var.users
  name = format("%s/%s/%s/%s/%s-rds-credentials",
    local.secret_store_path,
    local.psql.engine,
    local.psql.server_name,
    replace((try(each.value.db_ref, "") != "" ?
      postgresql_database.this[each.value.db_ref].name
      : each.value.database_name
    ), "_", "-"),
    replace(postgresql_role.user[each.key].name, "_", "-")
  )
  description = "RDS User Credentials - ${postgresql_role.user[each.key].name} - Grants: ${each.value.grant} - ${local.psql.engine} - ${local.psql.server_name}"
  tags = merge(local.all_tags, {
    "rds-username" = postgresql_role.user[each.key].name
    "rds-datatabase-name" = (try(each.value.db_ref, "") != "" ?
      postgresql_database.this[each.value.db_ref].name
      : each.value.database_name
    )
    "rds-server-name" = local.psql.server_name
  })
}

resource "aws_secretsmanager_secret_version" "user" {
  for_each  = var.users
  secret_id = aws_secretsmanager_secret.user[each.key].id
  secret_string = jsonencode(merge(
    {
      username = postgresql_role.user[each.key].name
      password = random_password.user[each.key].result
      host = local.hoop_connect ? (
        try(var.hoop.cluster, false) ? data.aws_rds_cluster.hoop_db_server[0].endpoint :
        data.aws_db_instance.hoop_db_server[0].endpoint
      ) : local.psql.host
      port = local.hoop_connect ? (
        try(var.hoop.cluster, false) ? data.aws_rds_cluster.hoop_db_server[0].port :
        data.aws_db_instance.hoop_db_server[0].port
      ) : local.psql.port
      dbname = try(each.value.db_ref, "") != "" ? postgresql_database.this[each.value.db_ref].name : each.value.database_name
      sslmode = local.hoop_connect ? var.hoop.default_sslmode : local.psql.sslmode
      engine  = local.psql.engine
    },
    length(data.aws_secretsmanager_secret.db_password) > 0 ? {
      masterarn = data.aws_secretsmanager_secret.db_password[0].arn
    } : {}
    )
  )
}

