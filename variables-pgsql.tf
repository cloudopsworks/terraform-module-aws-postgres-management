##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

## Users definition - YAML format
# users:
#   <user_ref>:
#     name: "username"               # (Required) Name of the user.
#     grant: "owner"                 # (Required) Grant type for the user. Possible values: owner, readwrite, readonly.
#     db_ref: "db_ref"               # (Optional) Reference to the database this user is associated with. Defaults to the default dbname of server.
#     database_name: "dbname"        # (Optional) Name of the database this user is associated with. Defaults to the default dbname of server.
#     database_owner: "dbname_ow"    # (Conditionally Required) Owner role to grant when grant=owner and no db_ref is provided. No default.
#     schema: "public"               # (Optional) Schema this user is associated with. Defaults to public.
#     login: true                    # (Optional) If the user can login. Defaults to true.
#     superuser: false               # (Optional) If the user is a superuser. Defaults to false.
#     create_database: false         # (Optional) If the user can create databases. Defaults to false.
#     replication: false             # (Optional) If the user can replicate. Defaults to false.
#     encrypted_password: true       # (Optional) If the password is encrypted. Defaults to true.
#     inherit: true                  # (Optional) If the user inherits privileges from the parent role. Defaults to true.
#     create_role: false             # (Optional) If the user can create roles. Defaults to false.
#     connection_limit: -1           # (Optional) Connection limit for the user. Defaults to -1 (no limit).
#     import: false                  # (Optional) If the user should be imported. Defaults to false.
#     hoop:                          # (Optional) Hoop settings for the user.
#       access_control: ["group"]    # (Optional) List of access control groups for hoop. Defaults to [].
variable "users" {
  description = "Users and user attributes - see docs for example"
  type        = any
  default     = {}
}

## Roles definition - YAML format
# roles:
#   <role_ref>:
#     name: "rolename"               # (Required) Name of the role.
#     grant: "owner"                 # (Required) Grant type for the role. Possible values: owner, readwrite, readonly.
#     db_ref: "db_ref"               # (Optional) Reference to the database this role is associated with. Defaults to the default dbname of server.
#     database_name: "dbname"        # (Optional) Name of the database this role is associated with. Defaults to the default dbname of server.
#     schema: "public"               # (Optional) Schema this role is associated with. Defaults to public.
#     create_database: false         # (Optional) If the role can create databases. Defaults to false.
#     replication: false             # (Optional) If the role can replicate. Defaults to false.
#     inherit: true                  # (Optional) If the role inherits privileges from the parent role. Defaults to true.
#     create_role: false             # (Optional) If the role can create roles. Defaults to false.
#     connection_limit: -1           # (Optional) Connection limit for the role. Defaults to -1 (no limit).
#     import: false                  # (Optional) If the role should be imported. Defaults to false.
variable "roles" {
  description = "Roles and role attributes - see docs for example"
  type        = any
  default     = {}
}

## Databases definition - YAML format
# databases:
#   <db_ref>:
#     name: "dbname"                 # (Required) Name of the database.
#     create_owner: false            # (Optional) If the database should be created with an owner. Defaults to false.
#     owner: "ownername"             # (Optional) Owner of the database, required if create_owner is false.
#     collate: "en_US.UTF-8"         # (Optional) Collate of the database. Defaults to en_US.UTF-8.
#     ctype: "en_US.UTF-8"           # (Optional) Ctype of the database. Defaults to en_US.UTF-8.
#     connection_limit: -1           # (Optional) Connection limit for the database. Defaults to -1 (no limit).
#     is_template: false             # (Optional) If the database is a template. Defaults to false.
#     template: "template0"          # (Optional) Name of the template to use for the database. Defaults to template0.
#     encoding: "UTF8"               # (Optional) Encoding of the database. Defaults to UTF8.
#     allow_connections: true        # (Optional) If the database allows connections. Defaults to true.
#     alter_object_ownership: false  # (Optional) If the database should alter object ownership. Defaults to false.
#     import: false                  # (Optional) If the database should be imported. Defaults to false.
#     schemas:                       # (Optional) List of schemas to create in the database. Defaults to [].
#       - name: "schema_name"        # (Required) Name of the schema.
#         owner: "schema_owner"      # (Optional) Owner of the schema, can be user_ref or name. Defaults to the database owner.
#         reuse: true                # (Optional) If the schema should be reused if it already exists. Defaults to true.
#         cascade_on_delete: false   # (Optional) If the schema should be deleted with cascade. Defaults to false.
#     hoop:                          # (Optional) Hoop settings for the database.
#       access_control: ["group"]    # (Optional) List of access control groups for hoop. Defaults to [].
variable "databases" {
  description = "Databases and database attributes - see docs for example"
  type        = any
  default     = {}
}

## Hoop attributes - YAML format
# hoop:
#   enabled: false                   # (Optional) If hoop should be enabled. Defaults to false.
#   agent_id: "agent-uuid"           # (Required if enabled) UUID of the Hoop agent.
#   community: true                  # (Optional) Use community secret prefix (_aws:) vs enterprise (_envs/aws#); default: true
#   import: false                    # (Optional) Import existing Hoop connection; default: false
#   default_sslmode: "require"       # (Optional) Default SSL mode for hoop. Defaults to require.
#   tags: {key: "value"}             # (Optional) Tags map for Hoop connection.
#   access_control: ["group"]        # (Optional) Global access control groups for hoop. Defaults to [].
#   server_name: "server"            # (Optional) Server name for hoop.
#   cluster: false                   # (Optional) If the server is a cluster. Defaults to false.
#   engine: "postgres"               # (Optional) Engine for hoop. Defaults to postgres.
#   db_name: "postgres"              # (Optional) Default database name for hoop.
#   superuser: false                 # (Optional) If the hoop user is a superuser. Defaults to false.
#   port: 5433                       # (Optional) Port for hoop connection. Defaults to 5433.
#   username: "noop"                 # (Optional) Username for hoop connection. Defaults to noop.
#   password: "noop"                 # (Optional) Password for hoop connection. Defaults to noop.
variable "hoop" {
  description = "Hoop attributes - see docs for example"
  type        = any
  default     = {}
}

## RDS attributes - YAML format
# rds:
#   enabled: false                   # (Optional) If RDS integration should be enabled. Defaults to false.
#   name: "rds-name"                 # (Optional) Name of the RDS instance. Required if enabled is true.
#   secret_name: "secret-name"       # (Optional) Name of the RDS secret in Secrets Manager. Required if enabled is true.
#   cluster: false                   # (Optional) If the RDS is an Aurora RDS Cluster. Defaults to false.
#   from_secret: false               # (Optional) If the RDS configuration should be read from a secret. Defaults to false.
#   server_name: "server"            # (Optional) Server name override.
#   engine: "postgres"               # (Optional) RDS Engine.
#   sslmode: "require"               # (Optional) SSL mode for RDS connection. Defaults to require.
#   superuser: false                 # (Optional) If the RDS master user is a superuser. Defaults to false.
variable "rds" {
  description = "RDS attributes - see docs for example"
  type        = any
  default     = {}
}

## Direct connection attributes - YAML format
# direct:
#   server_name: "server"            # (Required) Server name for direct connection.
#   host: "localhost"                # (Required) Host for direct connection.
#   port: 5432                       # (Required) Port for direct connection.
#   username: "user"                 # (Required) Username for direct connection.
#   password: "pass"                 # (Required) Password for direct connection.
#   engine: "postgres"               # (Required) Engine for direct connection.
#   db_name: "postgres"              # (Required) Database name for direct connection.
#   sslmode: "require"               # (Required) SSL mode for direct connection.
#   jump_host: "bastion"             # (Optional) Jump host for SSH tunneling.
#   jump_port: 22                    # (Optional) Jump port for SSH tunneling.
#   superuser: false                 # (Optional) If the direct user is a superuser. Defaults to false.
variable "direct" {
  description = "Direct connection attributes - see docs for example"
  type        = any
  default     = {}
}

# password_rotation_period: 90       # (Optional) Password rotation period in days. Defaults to 90.
variable "password_rotation_period" {
  description = "Password rotation period in days"
  type        = number
  default     = 90
}


# secrets_kms_key_id: "key-id"       # (Optional) KMS Key ID to use to encrypt data in Secrets Manager. Can be ARN or Alias.
variable "secrets_kms_key_id" {
  description = "(optional) KMS Key ID to use to encrypt data in this secret, can be ARN or KMS Alias"
  type        = string
  default     = null
}

# rotation_lambda_name: "lambda"     # (Optional) Name of the lambda function to rotate the password.
variable "rotation_lambda_name" {
  description = "Name of the lambda function to rotate the password"
  type        = string
  default     = ""
}

# rotation_duration: "1h"            # (Optional) Duration of the lambda function to rotate the password. Defaults to 1h.
variable "rotation_duration" {
  description = "Duration of the lambda function to rotate the password"
  type        = string
  default     = "1h"
}

# rotate_immediately: false          # (Optional) Rotate the password immediately. Defaults to false.
variable "rotate_immediately" {
  description = "Rotate the password immediately"
  type        = bool
  default     = false
}

# force_reset: false                 # (Optional) Force reset the password. Defaults to false.
variable "force_reset" {
  description = "Force Reset the password"
  type        = bool
  default     = false
}