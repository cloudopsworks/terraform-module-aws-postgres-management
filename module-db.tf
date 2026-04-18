##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  rotated_owner_passwords = {
    for key, db in var.databases :
    key => jsondecode(data.aws_secretsmanager_secret_version.owner_rotated[key].secret_string)["password"]
    if try(db.create_owner, false) && var.rotation_lambda_name != "" &&
    length(try(data.aws_secretsmanager_secrets.owner[key].names, [])) > 0 &&
    length(try(data.aws_secretsmanager_secret_versions.owner_rotated[key].versions, [])) > 0
  }
  rotated_user_passwords = {
    for key, user in var.users :
    key => jsondecode(data.aws_secretsmanager_secret_version.user_rotated[key].secret_string)["password"]
    if var.rotation_lambda_name != "" &&
    length(try(data.aws_secretsmanager_secrets.user[key].names, [])) > 0 &&
    length(try(data.aws_secretsmanager_secret_versions.user_rotated[key].versions, [])) > 0
  }
}

module "db" {
  source    = "git::https://github.com/cloudopsworks/terraform-module-postgres-management.git?ref=v1.0.0"
  providers = { postgresql = postgresql }

  databases                = var.databases
  users                    = var.users
  roles                    = var.roles
  password_rotation_period = var.password_rotation_period
  force_reset              = var.force_reset
  rotation_lambda_name     = var.rotation_lambda_name
  rotated_owner_passwords  = local.rotated_owner_passwords
  rotated_user_passwords   = local.rotated_user_passwords
}
