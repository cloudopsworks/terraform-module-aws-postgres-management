<!-- 
  ** DO NOT EDIT THIS FILE
  ** 
  ** This file was automatically generated. 
  ** 1) Make all changes to `README.yaml` 
  ** 2) Run `make init` (you only need to do this once)
  ** 3) Run`make readme` to rebuild this file. 
  -->
[![README Header][readme_header_img]][readme_header_link]

[![cloudopsworks][logo]](https://cloudops.works/)

# Terraform Module for AWS RDS PostgreSQL database and User Management




This module manages AWS RDS for PostgreSQL databases and automates user management with 
comprehensive security features. It provides automated user creation, password rotation, 
and role management capabilities integrated with AWS Secrets Manager. The module handles 
database instance provisioning, automated backups, maintenance windows, parameter groups, 
and security group management, supporting multi-AZ deployments, encryption at rest, and 
automated minor version upgrades.


---

This project is part of our comprehensive approach towards DevOps Acceleration. 
[<img align="right" title="Share via Email" width="24" height="24" src="https://docs.cloudops.works/images/ionicons/ios-mail.svg"/>][share_email]
[<img align="right" title="Share on Google+" width="24" height="24" src="https://docs.cloudops.works/images/ionicons/logo-googleplus.svg" />][share_googleplus]
[<img align="right" title="Share on Facebook" width="24" height="24" src="https://docs.cloudops.works/images/ionicons/logo-facebook.svg" />][share_facebook]
[<img align="right" title="Share on Reddit" width="24" height="24" src="https://docs.cloudops.works/images/ionicons/logo-reddit.svg" />][share_reddit]
[<img align="right" title="Share on LinkedIn" width="24" height="24" src="https://docs.cloudops.works/images/ionicons/logo-linkedin.svg" />][share_linkedin]
[<img align="right" title="Share on Twitter" width="24" height="24" src="https://docs.cloudops.works/images/ionicons/logo-twitter.svg" />][share_twitter]


[![Terraform Open Source Modules](https://docs.cloudops.works/images/terraform-open-source-modules.svg)][terraform_modules]



It's 100% Open Source and licensed under the [APACHE2](LICENSE).







We have [*lots of terraform modules*][terraform_modules] that are Open Source and we are trying to get them well-maintained!. Check them out!






## Introduction

### Introduction

The **Terraform Module for AWS RDS PostgreSQL database and User Management** is designed 
to provide comprehensive database management capabilities, focusing on user roles, schema management,
and automated password rotation. The module supports both standard password management and
AWS Secrets Manager integration for enhanced security.

#### Key Features
- Database user and role management with fine-grained permissions
- Schema creation and ownership management
- Automated password rotation with configurable periods
- AWS Secrets Manager integration
- Database owner role management
- Custom connection limits per user
- Role inheritance and grant capabilities
- Secure password generation with customizable requirements
- Support for multiple databases and schemas
- Flexible user permission configurations

## Usage


**IMPORTANT:** The `master` branch is used in `source` just as an example. In your code, do not pin to `master` because there may be breaking changes between releases.
Instead pin to the release tag (e.g. `?ref=vX.Y.Z`) of one of our [latest releases](https://github.com/cloudopsworks/terraform-module-aws-postgres-management/releases).


### How to Use this Project

#### Prerequisites
- Terraform >= 1.0
- Terragrunt >= 0.36
- AWS Provider >= 4.0
- PostgreSQL Provider

#### Main Configuration Options

1. **Database Configuration**
```yaml
databases:
  main:
    name: "myapp"
    create_owner: true
    schemas:
      - name: "app_schema"
        owner: "app_user"
        reuse: true
      - name: "audit_schema"
        owner: "audit_user"
        cascade_on_delete: true
```

2. **User Management**
```yaml
users:
  app_user:
    name: "application"
    login: true
    create_database: false
    connection_limit: 100
    inherit: true

  admin_user:
    name: "dbadmin"
    login: true
    superuser: true
    create_role: true
```

3. **Role Configuration**
```yaml
roles:
  read_only:
    name: "readonly"
    inherit: true
    login: false
    connection_limit: 50

  power_user:
    name: "power_user"
    create_database: true
    create_role: true
```

4. **Password Rotation**
```yaml
# Standard rotation
password_rotation_period: 90

# AWS Secrets Manager rotation
rotation_lambda_name: "db-password-rotation"
force_reset: false  # Force password reset on apply
```

#### Implementation Steps
1. **Add module source** to your Terragrunt configuration:
   ```hcl
   source = "git::https://github.com/cloudopsworks/terraform-module-aws-postgres-management.git?ref=v1.0.0"
   ```

2. **Configure variables** in your configuration files
3. **Apply the configuration**:
   ```bash
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

## Quick Start

# Quickstart

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- Terragrunt >= 0.36.0

### Step-by-Step Guide
1. **Create Project Structure**:
   ```bash
   mkdir -p myproject/postgres
   cd myproject/postgres
   ```

2. **Create Terragrunt Configuration**:
   Create `terragrunt.hcl`:
   ```hcl
   terraform {
     source = "git::https://github.com/cloudopsworks/terraform-module-aws-postgres-management.git?ref=v1.0.0"
   }

   inputs = {
     identifier = "myapp-postgres"
     engine_version = "14.5"
     instance_class = "db.t3.medium"
     database_name = "myapp"
     vpc_id = "vpc-12345678"
     subnet_ids = ["subnet-a1b2c3d4", "subnet-e5f6g7h8"]

     users = {
       app = {
         name = "application"
         login = true
         connection_limit = 100
       }
       admin = {
         name = "dbadmin"
         login = true
         superuser = true
       }
     }

     password_rotation_period = 90
     rotation_lambda_name = "db-password-rotation"
   }
   ```

3. **Initialize and Deploy**:
   ```bash
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

4. **Verify Deployment**:
   ```bash
   terragrunt output
   aws rds describe-db-instances --db-instance-identifier myapp-postgres
   ```

5. **Retrieve User Credentials**:
   ```bash
   # For non-rotated passwords
   terragrunt output -json user_passwords

   # For rotated passwords
   aws secretsmanager get-secret-value --secret-id myapp-postgres-application
   ```

6. **Connect to Database**:
   ```bash
   psql -h $(terragrunt output -raw endpoint) -U application -d myapp
   ```

By following these steps, you will have a running Amazon RDS for PostgreSQL instance with 
configured users and automated password rotation.

### Next Steps
- Configure additional security groups
- Set up monitoring and alerting
- Implement backup strategies
- Configure read replicas if needed
- Set up additional database users and roles
- Configure password rotation policies


## Examples

### Example Usage

#### Basic Configuration (terragrunt.hcl)
```hcl
terraform {
  source = "git::https://github.com/cloudopsworks/terraform-module-aws-postgres-management.git?ref=v1.0.0"
}

inputs = {
  identifier = "myapp-postgres"
  engine_version = "14.5"
  instance_class = "db.t3.medium"
  allocated_storage = 20

  database_name = "myapp"
  master_username = "dbadmin"

  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  backup_retention_period = 7
  multi_az = true
  storage_encrypted = true

  users = {
    app = {
      name = "application"
      login = true
      connection_limit = 100
    }
    admin = {
      name = "dbadmin"
      login = true
      superuser = true
    }
  }

  password_rotation_period = 90
  rotation_lambda_name = "db-password-rotation"

  extra_tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

#### Production Configuration (production/inputs.yaml)
```yaml
# Database Settings
instance_class: "db.r6g.xlarge"
allocated_storage: 100
max_allocated_storage: 500

# High Availability
multi_az: true
backup_retention_period: 30

# Performance
performance_insights_enabled: true
monitoring_interval: 60

# Security
storage_encrypted: true
deletion_protection: true

# User Management
users:
  app_user:
    name: "application"
    login: true
    create_database: false
    connection_limit: 100
    grant: "owner"
  readonly_user:
    name: "readonly"
    login: true
    inherit: true
    connection_limit: 50
  admin_user:
    name: "dbadmin"
    login: true
    superuser: true
    create_database: true

# Password Management
password_rotation_period: 90
rotation_lambda_name: "db-password-rotation"
force_reset: false
```

You can place this `terragrunt.hcl` file in a directory that also contains the relevant 
YAML files (e.g., `inputs.yaml`) and any other shared configuration.

Refer to your own file structure layout for environment-specific overrides, naming conventions, 
and relationships with other modules.



## Makefile Targets
```
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform/opentofu code
  tag                                 Tag the current version

```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | ~> 1.25 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | 1.25.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.13.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.9 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.owner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_rotation.owner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_rotation.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_version.owner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.owner_rotated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.user_rotated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [null_resource.hoop_connection_owners](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.hoop_connection_users](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [postgresql_database.this](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/database) | resource |
| [postgresql_default_privileges.user_func_def_priv](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.user_ro_tab_def_priv](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.user_seq_def_priv](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.user_tab_def_priv](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.user_types_def_priv](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_grant.user_all_db](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.user_all_schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.user_connect](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.user_func_def_priv](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.user_ro_tab_def_priv](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.user_seq_def_priv](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.user_tab_def_priv](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant.user_usage_schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_grant_role.provided_owner](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant_role) | resource |
| [postgresql_role.owner](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [postgresql_role.role](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [postgresql_role.user](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [postgresql_schema.database_schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/schema) | resource |
| [random_password.owner](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.owner_initial](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.user](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.user_initial](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [time_rotating.owner](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [time_rotating.user](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [aws_db_instance.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance) | data source |
| [aws_db_instance.hoop_db_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance) | data source |
| [aws_lambda_function.rotation_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_function) | data source |
| [aws_rds_cluster.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_cluster) | data source |
| [aws_rds_cluster.hoop_db_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_cluster) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret.db_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.db_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.owner_rotated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.user_rotated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_versions.owner_rotated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_versions) | data source |
| [aws_secretsmanager_secret_versions.user_rotated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_versions) | data source |
| [aws_secretsmanager_secrets.owner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secrets) | data source |
| [aws_secretsmanager_secrets.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secrets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databases"></a> [databases](#input\_databases) | Databases and database attributes - see docs for example | `any` | `{}` | no |
| <a name="input_direct"></a> [direct](#input\_direct) | Direct connection attributes - see docs for example | `any` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Extra tags to add to the resources | `map(string)` | `{}` | no |
| <a name="input_force_reset"></a> [force\_reset](#input\_force\_reset) | Force Reset the password | `bool` | `false` | no |
| <a name="input_hoop"></a> [hoop](#input\_hoop) | Hoop attributes - see docs for example | `any` | `{}` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | Is this a hub or spoke configuration? | `bool` | `false` | no |
| <a name="input_org"></a> [org](#input\_org) | Organization details | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_password_rotation_period"></a> [password\_rotation\_period](#input\_password\_rotation\_period) | Password rotation period in days | `number` | `90` | no |
| <a name="input_rds"></a> [rds](#input\_rds) | RDS attributes - see docs for example | `any` | `{}` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Roles and role attributes - see docs for example | `any` | `{}` | no |
| <a name="input_rotate_immediately"></a> [rotate\_immediately](#input\_rotate\_immediately) | Rotate the password immediately | `bool` | `false` | no |
| <a name="input_rotation_duration"></a> [rotation\_duration](#input\_rotation\_duration) | Duration of the lambda function to rotate the password | `string` | `"1h"` | no |
| <a name="input_rotation_lambda_name"></a> [rotation\_lambda\_name](#input\_rotation\_lambda\_name) | Name of the lambda function to rotate the password | `string` | `""` | no |
| <a name="input_run_hoop"></a> [run\_hoop](#input\_run\_hoop) | Run hoop with agent, be careful with this option, it will run the HOOP command in output in a null\_resource | `bool` | `false` | no |
| <a name="input_secrets_kms_key_id"></a> [secrets\_kms\_key\_id](#input\_secrets\_kms\_key\_id) | (optional) KMS Key ID to use to encrypt data in this secret, can be ARN or KMS Alias | `string` | `null` | no |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | Spoke ID Number, must be a 3 digit number | `string` | `"001"` | no |
| <a name="input_users"></a> [users](#input\_users) | Users and user attributes - see docs for example | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hoop_connection_owners"></a> [hoop\_connection\_owners](#output\_hoop\_connection\_owners) | n/a |
| <a name="output_hoop_connection_users"></a> [hoop\_connection\_users](#output\_hoop\_connection\_users) | n/a |
| <a name="output_owners"></a> [owners](#output\_owners) | n/a |
| <a name="output_users"></a> [users](#output\_users) | n/a |



## Help

**Got a question?** We got answers. 

File a GitHub [issue](https://github.com/cloudopsworks/terraform-module-aws-postgres-management/issues), send us an [email][email] or join our [Slack Community][slack].

[![README Commercial Support][readme_commercial_support_img]][readme_commercial_support_link]

## DevOps Tools

## Slack Community


## Newsletter

## Office Hours

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudopsworks/terraform-module-aws-postgres-management/issues) to report any bugs or file feature requests.

### Developing




## Copyrights

Copyright © 2024-2025 [Cloud Ops Works LLC](https://cloudops.works)





## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.









## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

This project is maintained by [Cloud Ops Works LLC][website]. 


### Contributors

|  [![Cristian Beraha][berahac_avatar]][berahac_homepage]<br/>[Cristian Beraha][berahac_homepage] |
|---|

  [berahac_homepage]: https://github.com/berahac
  [berahac_avatar]: https://github.com/berahac.png?size=50

[![README Footer][readme_footer_img]][readme_footer_link]
[![Beacon][beacon]][website]

  [logo]: https://cloudops.works/logo-300x69.svg
  [docs]: https://cowk.io/docs?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=docs
  [website]: https://cowk.io/homepage?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=website
  [github]: https://cowk.io/github?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=github
  [jobs]: https://cowk.io/jobs?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=jobs
  [hire]: https://cowk.io/hire?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=hire
  [slack]: https://cowk.io/slack?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=slack
  [linkedin]: https://cowk.io/linkedin?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=linkedin
  [twitter]: https://cowk.io/twitter?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=twitter
  [testimonial]: https://cowk.io/leave-testimonial?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=testimonial
  [office_hours]: https://cloudops.works/office-hours?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=office_hours
  [newsletter]: https://cowk.io/newsletter?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=newsletter
  [email]: https://cowk.io/email?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=email
  [commercial_support]: https://cowk.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=commercial_support
  [we_love_open_source]: https://cowk.io/we-love-open-source?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=we_love_open_source
  [terraform_modules]: https://cowk.io/terraform-modules?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=terraform_modules
  [readme_header_img]: https://cloudops.works/readme/header/img
  [readme_header_link]: https://cloudops.works/readme/header/link?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=readme_header_link
  [readme_footer_img]: https://cloudops.works/readme/footer/img
  [readme_footer_link]: https://cloudops.works/readme/footer/link?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=readme_footer_link
  [readme_commercial_support_img]: https://cloudops.works/readme/commercial-support/img
  [readme_commercial_support_link]: https://cloudops.works/readme/commercial-support/link?utm_source=github&utm_medium=readme&utm_campaign=cloudopsworks/terraform-module-aws-postgres-management&utm_content=readme_commercial_support_link
  [share_twitter]: https://twitter.com/intent/tweet/?text=Terraform+Module+for+AWS+RDS+PostgreSQL+database+and+User+Management&url=https://github.com/cloudopsworks/terraform-module-aws-postgres-management
  [share_linkedin]: https://www.linkedin.com/shareArticle?mini=true&title=Terraform+Module+for+AWS+RDS+PostgreSQL+database+and+User+Management&url=https://github.com/cloudopsworks/terraform-module-aws-postgres-management
  [share_reddit]: https://reddit.com/submit/?url=https://github.com/cloudopsworks/terraform-module-aws-postgres-management
  [share_facebook]: https://facebook.com/sharer/sharer.php?u=https://github.com/cloudopsworks/terraform-module-aws-postgres-management
  [share_googleplus]: https://plus.google.com/share?url=https://github.com/cloudopsworks/terraform-module-aws-postgres-management
  [share_email]: mailto:?subject=Terraform+Module+for+AWS+RDS+PostgreSQL+database+and+User+Management&body=https://github.com/cloudopsworks/terraform-module-aws-postgres-management
  [beacon]: https://ga-beacon.cloudops.works/G-7XWMFVFXZT/cloudopsworks/terraform-module-aws-postgres-management?pixel&cs=github&cm=readme&an=terraform-module-aws-postgres-management
