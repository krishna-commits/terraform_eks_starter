variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
  default     = ""
}

variable "stage" {
  type        = string
  description = "Environment, e.g. 'prod', 'staging', 'dev', or 'test'"
  default     = ""
}

variable "name" {
  type        = string
  default     = "app"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `{ BusinessUnit = \"XYZ\" }`"
}

variable "enabled" {
  type        = bool
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
  default     = true
}

variable "workers_role_name" {
  type        = string
  description = "Role ARN name of worker nodes"
}
