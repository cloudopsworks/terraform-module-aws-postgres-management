##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  owner_list = {
    for key, db in var.databases : key => "${db.name}_ow" if try(db.create_owner, false)
  }
}

resource "postgresql_database" "this" {
  for_each               = var.databases
  name                   = each.value.name
  owner                  = try(each.value.create_owner, false) ? local.owner_list[each.key] : each.value.owner
  lc_collate             = try(each.value.collate, null)
  lc_ctype               = try(each.value.ctype, null)
  connection_limit       = try(each.value.connection_limit, -1)
  is_template            = try(each.value.is_template, null)
  template               = try(each.value.from_template, null)
  encoding               = try(each.value.encoding, null)
  allow_connections      = try(each.value.allow_connections, null)
  alter_object_ownership = try(each.value.alter_object_ownership, null)
}

resource "time_rotating" "owner" {
  for_each = {
    for key, db in var.databases : key => db if try(db.create_owner, false) && var.rotation_lambda_name == ""
  }
  rotation_days = var.password_rotation_period
}

resource "random_password" "owner" {
  for_each = {
    for key, db in var.databases : key => db if try(db.create_owner, false) && var.rotation_lambda_name == ""
  }
  length           = 25
  special          = true
  override_special = "=_-+@~#"
  min_upper        = 2
  min_special      = 2
  min_numeric      = 2
  min_lower        = 2
  lifecycle {
    replace_triggered_by = [
      time_rotating.owner[each.key].rotation_rfc3339
    ]
  }
}

resource "random_password" "owner_initial" {
  for_each = {
    for key, db in var.databases : key => db if try(db.create_owner, false) && var.rotation_lambda_name != ""
  }
  length           = 25
  special          = true
  override_special = "=_-+@~#"
  min_upper        = 2
  min_special      = 2
  min_numeric      = 2
  min_lower        = 2
}

resource "postgresql_role" "owner" {
  for_each = {
    for key, db in var.databases : key => db if try(db.create_owner, false)
  }
  name = local.owner_list[each.key]
  password = var.rotation_lambda_name == "" ? random_password.owner[each.key].result : (
    try(length(data.aws_secretsmanager_secret_versions.owner_rotated[each.key].versions), 0) > 0 && !var.force_reset ?
    jsondecode(data.aws_secretsmanager_secret_version.owner_rotated[each.key].secret_string)["password"] :
    random_password.owner_initial[each.key].result
  )
  encrypted_password = true
  create_role        = true
  login              = true
}

resource "postgresql_grant_role" "provided_owner" {
  for_each = {
    for key, db in var.databases : key => db if !try(db.create_owner, false)
  }
  grant_role = each.value.owner
  role       = local.psql.admin_user
}

