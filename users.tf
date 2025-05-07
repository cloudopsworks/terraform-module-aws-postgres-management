##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

resource "time_rotating" "user" {
  for_each = {
    for k, user in var.users : k => user if var.rotation_lambda_name == ""
  }
  rotation_days = var.password_rotation_period
}

resource "random_password" "user" {
  for_each = {
    for k, user in var.users : k => user if var.rotation_lambda_name == ""
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
      time_rotating.user[each.key].rotation_rfc3339
    ]
  }
}

resource "random_password" "user_initial" {
  for_each = {
    for k, user in var.users : k => user if var.rotation_lambda_name != ""
  }
  length           = 25
  special          = true
  override_special = "=_-+@~#"
  min_upper        = 2
  min_special      = 2
  min_numeric      = 2
  min_lower        = 2
}

resource "postgresql_role" "user" {
  for_each = var.users
  name     = each.value.name
  password = var.rotation_lambda_name == "" ? random_password.user[each.key].result : (
    try(length(data.aws_secretsmanager_secret_versions.user_rotated[each.key].versions), 0) > 0 && !var.force_reset ?
    jsondecode(data.aws_secretsmanager_secret_version.user_rotated[each.key].secret_string)["password"] :
    random_password.user_initial[each.key].result
  )
  login              = try(each.value.login, true)
  superuser          = try(each.value.superuser, null)
  create_database    = try(each.value.create_database, null)
  replication        = try(each.value.replication, null)
  encrypted_password = try(each.value.encrypted_password, true)
  connection_limit   = try(each.value.connection_limit, -1)
  inherit            = try(each.value.inherit, null)
  create_role        = try(each.value.create_role, null)
  roles              = try(each.value.grant, "") == "owner" ? [local.admin_role[each.key].admin_role] : []
}
