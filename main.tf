##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# Import blocks for resources managed by module.db
# These must be in the root module since import blocks cannot be in child modules.
# Existing rotation-enabled workspaces must also run a one-time:
#   tofu state mv module.db.postgresql_role.owner[<key>] module.db.postgresql_role.owner_rotated[<key>]
#   tofu state mv module.db.postgresql_role.user[<key>]  module.db.postgresql_role.user_rotated[<key>]
# Terraform cannot encode this split as a safe static moved block while both rotation modes remain supported.

import {
  for_each = {
    for k, db in var.databases : k => db if try(db.import, false)
  }
  to = module.db.postgresql_database.this[each.key]
  id = each.value.name
}

import {
  for_each = {
    for k, db in var.databases : k => db if try(db.import, false) && try(db.create_owner, false) && var.rotation_lambda_name == ""
  }
  to = module.db.postgresql_role.owner[each.key]
  id = "${each.value.name}_ow"
}

import {
  for_each = {
    for k, db in var.databases : k => db if try(db.import, false) && try(db.create_owner, false) && var.rotation_lambda_name != ""
  }
  to = module.db.postgresql_role.owner_rotated[each.key]
  id = "${each.value.name}_ow"
}

import {
  for_each = {
    for k, user in var.users : k => user if try(user.import, false) && var.rotation_lambda_name == ""
  }
  to = module.db.postgresql_role.user[each.key]
  id = each.value.name
}

import {
  for_each = {
    for k, user in var.users : k => user if try(user.import, false) && var.rotation_lambda_name != ""
  }
  to = module.db.postgresql_role.user_rotated[each.key]
  id = each.value.name
}

import {
  for_each = {
    for k, role in var.roles : k => role if try(role.import, false)
  }
  to = module.db.postgresql_role.role[each.key]
  id = each.value.name
}
