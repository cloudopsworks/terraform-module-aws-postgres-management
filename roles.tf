##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# Roles have no passwords.
resource "postgresql_role" "role" {
  for_each         = var.roles
  name             = each.value.name
  login            = false
  superuser        = try(each.value.superuser, null)
  create_database  = try(each.value.create_database, null)
  replication      = try(each.value.replication, null)
  connection_limit = try(each.value.connection_limit, -1)
  inherit          = try(each.value.inherit, null)
  create_role      = try(each.value.create_role, null)
  roles            = try(each.value.grant, "") == "owner" ? [local.admin_role[each.key].admin_role] : []
}
