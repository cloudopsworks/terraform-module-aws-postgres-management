##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  hoop_tags = length(try(var.hoop.tags, [])) > 0 ? join(" ", [for v in var.hoop.tags : "--tags \"${v}\""]) : ""
  hoop_connection_owners = try(var.hoop.enabled, false) && strcontains(local.psql.engine, "postgres") ? {
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
  } : null
  hoop_connection_users = try(var.hoop.enabled, false) && strcontains(local.psql.engine, "postgres") ? {
    for key, role_user in postgresql_role.user : key => <<EOT
hoop admin create connection ${local.psql.server_name}-${(try(var.users[key].db_ref, "") != "" ? postgresql_database.this[var.users[key].db_ref].name : var.users[key].database_name)}-${role_user.name} \
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
  } : null
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
