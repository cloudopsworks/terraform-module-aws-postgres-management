##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# State migration: resources moved into module.db after refactoring

moved {
  from = postgresql_database.this
  to   = module.db.postgresql_database.this
}

moved {
  from = time_rotating.owner
  to   = module.db.time_rotating.owner
}

moved {
  from = random_password.owner
  to   = module.db.random_password.owner
}

moved {
  from = random_password.owner_initial
  to   = module.db.random_password.owner_initial
}

moved {
  from = postgresql_role.owner
  to   = module.db.postgresql_role.owner
}

moved {
  from = postgresql_grant_role.provided_owner
  to   = module.db.postgresql_grant_role.provided_owner
}

moved {
  from = postgresql_schema.database_schema
  to   = module.db.postgresql_schema.database_schema
}

moved {
  from = time_rotating.user
  to   = module.db.time_rotating.user
}

moved {
  from = random_password.user
  to   = module.db.random_password.user
}

moved {
  from = random_password.user_initial
  to   = module.db.random_password.user_initial
}

moved {
  from = postgresql_role.user
  to   = module.db.postgresql_role.user
}

moved {
  from = postgresql_role.role
  to   = module.db.postgresql_role.role
}

moved {
  from = postgresql_grant.user_all_db
  to   = module.db.postgresql_grant.user_all_db
}

moved {
  from = postgresql_grant.user_all_schema
  to   = module.db.postgresql_grant.user_all_schema
}

moved {
  from = postgresql_grant.user_usage_schema
  to   = module.db.postgresql_grant.user_usage_schema
}

moved {
  from = postgresql_default_privileges.user_tab_def_priv
  to   = module.db.postgresql_default_privileges.user_tab_def_priv
}

moved {
  from = postgresql_default_privileges.user_ro_tab_def_priv
  to   = module.db.postgresql_default_privileges.user_ro_tab_def_priv
}

moved {
  from = postgresql_grant.user_ro_tab_def_priv
  to   = module.db.postgresql_grant.user_ro_tab_def_priv
}

moved {
  from = postgresql_grant.user_connect
  to   = module.db.postgresql_grant.user_connect
}
