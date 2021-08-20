variable "namespace" {
  description = "Namespace (e.g. `singular` or `sg`)"
  type        = string
  default     = ""
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = string
  default     = ""
}


variable "enabled" {
  type        = bool
  default     = true
  description = "If module should be enabled or not"
}

variable "use_custom_image_id" {
  type        = bool
  default     = false
  description = "Use custom image id if flag to `true`"
}


variable "name" {
  description = "Name  (e.g. `app` or `cluster`)"
  type        = string
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
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where subnets will be created (e.g. `vpc-aceb2723`)"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "A list of CIDR blocks allowed to connect"

  default = [
    "0.0.0.0/0",
  ]
}

variable "ssh_user" {
  type        = string
  description = "Default SSH user for this AMI. e.g. `ec2user` for Amazon Linux and `ubuntu` for Ubuntu systems"
  default     = "ubuntu"
}

variable "user_data" {
  type        = list
  default     = []
  description = "User data content"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDS"
}


variable "region" {
  type        = string
  description = "Name of the AWS region to be used"
}

variable "ami_id" {
  type        = string
  description = "AMI ID of instance"
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "Instance type of bastion instance"
}

variable "min_size" {
  type        = number
  description = "The minimum size of autoscale group"
}

variable "max_size" {
  type        = number
  description = "The maximum size of autoscale group"
}

variable "desired_capacity" {
  type        = number
  description = "The desired capacity of autoscale group"
}

variable "destination_security_groups" {
  type        = list(string)
  description = "List of destination security group for egress SSH traffic"
  default     = []
}

variable "zone_id" {
  type        = string
  description = "Route 53 Zone ID "
  default     = ""
}

variable "cluster_name" {
  type        = string
  description = "Name of the eks cluster"
}
