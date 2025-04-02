##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#


resource "time_rotating" "user" {
  for_each      = var.users
  rotation_days = var.password_rotation_period
}

resource "random_password" "user" {
  for_each         = var.users
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

resource "postgresql_role" "user" {
  for_each           = var.users
  name               = each.value.name
  password           = random_password.user[each.key].result
  login              = try(each.value.login, true)
  superuser          = try(each.value.superuser, null)
  create_database    = try(each.value.create_database, null)
  replication        = try(each.value.replication, null)
  encrypted_password = try(each.value.encrypted_password, true)
  connection_limit   = try(each.value.connection_limit, -1)
  inherit            = try(each.value.inherit, null)
  create_role        = try(each.value.create_role, null)
  roles              = try(each.value.grant, "") == "owner" ? local.admin_role[each.key].admin_role : null
}
