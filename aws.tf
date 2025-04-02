##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
data "aws_region" "current" {}

data "aws_db_instance" "db" {
  count                  = try(var.rds.enabled, false) ? 1 : 0
  db_instance_identifier = var.rds.name
}

data "aws_secretsmanager_secret" "db_password" {
  count = try(var.rds.enabled, false) || try(var.rds.from_secret, false) ? 1 : 0
  name  = var.rds.secret_name
}

data "aws_secretsmanager_secret_version" "db_password" {
  count     = try(var.rds.enabled, false) || try(var.rds.from_secret, false) ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.db_password[0].id
}
