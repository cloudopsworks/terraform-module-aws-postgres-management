##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

variable "users" {
  description = "Users and user attributes - see docs for example"
  type        = any
  default     = {}
}

variable "databases" {
  description = "Databases and database attributes - see docs for example"
  type        = any
  default     = {}
}

variable "hoop" {
  description = "Hoop attributes - see docs for example"
  type        = any
  default     = {}
}

variable "rds" {
  description = "RDS attributes - see docs for example"
  type        = any
  default     = {}
}

variable "direct" {
  description = "Direct connection attributes - see docs for example"
  type        = any
  default     = {}
}

variable "password_rotation_period" {
  description = "Password rotation period in days"
  type        = number
  default     = 90
}

variable "run_hoop" {
  description = "Run hoop with agent, be careful with this option, it will run the HOOP command in output in a null_resource"
  type        = bool
  default     = false
}

variable "secrets_kms_key_id" {
  description = "(optional) KMS Key ID to use to encrypt data in this secret, can be ARN or KMS Alias"
  type        = string
  default     = null
}

variable "rotation_lambda_name" {
  description = "Name of the lambda function to rotate the password"
  type        = string
  default     = ""
}

variable "rotation_duration" {
  description = "Duration of the lambda function to rotate the password"
  type        = string
  default     = "1h"
}
