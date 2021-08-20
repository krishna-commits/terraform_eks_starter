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

variable "workers_role_arn" {
  type        = string
  description = "Role ARN of worker nodes"
}

variable "workers_role_name" {
  type        = string
  description = "Role ARN name of worker nodes"
}

variable "region" {
  type        = string
  description = "Aws region to use"
}

variable "controller_version" {
  type        = string
  default     = "1.1.2"
  description = "Version of alb-ingress-controller to use"
}

variable "cluster_name" {
  type        = string
  description = "Name of your k8 cluster"
}

variable "vpc_id" {
  type        = string
  description = "Name of the vpc your k8 cluster is in"
}

variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig"
}




