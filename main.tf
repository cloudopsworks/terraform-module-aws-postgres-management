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

import {
  for_each = {
    for k, db in var.databases : k => db if try(db.import, false)
  }
  to = module.db.postgresql_database.this[each.key]
  id = each.value.name
}

import {
  for_each = {
    for k, db in var.databases : k => db if try(db.import, false) && try(db.create_owner, false)
  }
  to = module.db.postgresql_role.owner[each.key]
  id = "${each.value.name}_ow"
}

import {
  for_each = {
    for k, user in var.users : k => user if try(user.import, false)
  }
  to = module.db.postgresql_role.user[each.key]
  id = each.value.name
}

import {
  for_each = {
    for k, role in var.roles : k => role if try(role.import, false)
  }
  to = module.db.postgresql_role.role[each.key]
  id = each.value.name
}
