##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  from_secret = try(var.rds.enabled, false) || try(var.rds.from_secret, false) ? jsondecode(data.aws_secretsmanager_secret_version.db_password[0].secret_string) : {}
  rds_secret_psql = try(var.rds.from_secret, false) ? {
    server_name = var.rds.server_name
    host        = local.from_secret["host"]
    port        = local.from_secret["port"]
    username    = local.from_secret["username"]
    admin_user  = local.from_secret["username"]
    password    = local.from_secret["password"]
    engine      = local.from_secret["engine"]
    db_name     = local.from_secret["dbname"]
    sslmode     = local.from_secret["sslmode"]
    superuser   = try(var.rds.superuser, false)
  } : {}
  rds_psql = try(var.rds.enabled, false) && !try(var.rds.cluster, false) ? {
    server_name = data.aws_db_instance.db[0].id
    host        = data.aws_db_instance.db[0].endpoint
    port        = data.aws_db_instance.db[0].port
    username    = data.aws_db_instance.db[0].master_username
    admin_user  = data.aws_db_instance.db[0].master_username
    engine      = data.aws_db_instance.db[0].engine
    password    = local.from_secret["password"]
    db_name     = data.aws_db_instance.db[0].db_name
    sslmode     = try(var.rds.sslmode, "required")
    superuser   = try(var.rds.superuser, false)
  } : {}
  rds_psql_c = try(var.rds.enabled, false) && try(var.rds.cluster, false) ? {
    server_name = data.aws_rds_cluster.db[0].cluster_identifier
    host        = data.aws_rds_cluster.db[0].endpoint
    port        = data.aws_rds_cluster.db[0].port
    username    = data.aws_rds_cluster.db[0].master_username
    admin_user  = data.aws_rds_cluster.db[0].master_username
    engine      = data.aws_rds_cluster.db[0].engine
    password    = local.from_secret["password"]
    db_name     = data.aws_rds_cluster.db[0].database_name
    sslmode     = try(var.rds.sslmode, "required")
    superuser   = try(var.rds.superuser, false)
  } : {}
  hoop_psql = try(var.hoop.enabled, false) ? {
    server_name = var.hoop.server_name
    host        = "localhost"
    port        = try(var.hoop.port, 5433)
    username    = try(var.hoop.username, "noop")
    password    = try(var.hoop.password, "noop")
    sslmode     = "disable"
    engine      = try(var.hoop.engine, "postgresql")
    admin_user  = var.hoop.admin_user
    db_name     = var.hoop.db_name
    superuser   = try(var.hoop.superuser, false)
  } : {}
  direct_psql = !try(var.rds.enabled, false) && !try(var.hoop.enabled, false) ? {
    server_name = var.direct.server_name
    host        = var.direct.host
    port        = var.direct.port
    username    = var.direct.username
    password    = var.direct.password
    engine      = var.direct.engine
    admin_user  = var.direct.username
    db_name     = var.direct.db_name
    sslmode     = var.direct.sslmode
    superuser   = try(var.direct.superuser, false)
  } : null
  psql = merge(
    local.rds_secret_psql,
    local.rds_psql,
    local.rds_psql_c,
    local.hoop_psql,
    local.direct_psql
  )
}

provider "postgresql" {
  host              = local.psql.host
  port              = local.psql.port
  username          = local.psql.username
  password          = local.psql.password
  database          = local.psql.db_name
  database_username = local.psql.admin_user
  sslmode           = local.psql.sslmode
  connect_timeout   = 15
  superuser         = local.psql.superuser
}