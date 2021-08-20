variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
  default     = ""
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  default     = ""
}

variable "name" {
  type        = string
  description = "Name  (e.g. `app` or `cluster`)"
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
  default     = true
  description = "Set to `false` to prevent the module from creating any resources"
}

variable "description" {
  default     = "ssh key"
  description = "Description of secret"
  type        = string
}

variable "secret_string" {
  description = "private key to add as value in secret"
  type        = string
}
