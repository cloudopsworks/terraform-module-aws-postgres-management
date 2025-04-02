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