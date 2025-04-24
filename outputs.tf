##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

output "owners" {
  value = {
    for key, db in var.databases : key => {
      username               = local.owner_list[key]
      credentials_secret     = aws_secretsmanager_secret.owner[key].name
      credentials_secret_arn = aws_secretsmanager_secret.owner[key].arn
    }
    if try(db.create_owner, false)
  }
}

output "users" {
  value = {
    for key, user in var.users : key => {
      username               = user.name
      credentials_secret     = aws_secretsmanager_secret.user[key].name
      credentials_secret_arn = aws_secretsmanager_secret.user[key].arn
    }
  }
}