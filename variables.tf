
variable "region" {
  description = "Name of the AWS region to be used"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to be used for a given region"
  type        = list(string)
  default     = []
}

variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "tags" {
  type = map(string)
  default = {
    Terraform : true
  }
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "cidr_block" {
  description = "CIDR block to be used for vpc"
  type        = string
}


variable "instance_type" {
  type        = string
  description = "Instance type to launch"
}

variable "kubernetes_version" {
  type        = string
  default     = ""
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
}

variable "health_check_type" {
  type        = string
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address with an instance in a VPC"
}

variable "max_size" {
  type        = number
  description = "The maximum size of the AutoScaling Group"
}

variable "min_size" {
  type        = number
  description = "The minimum size of the AutoScaling Group"
}

variable "wait_for_capacity_timeout" {
  type        = string
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior"
}

variable "autoscaling_policies_enabled" {
  type        = bool
  description = "Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling"
}

variable "cpu_utilization_high_threshold_percent" {
  type        = number
  description = "Worker nodes AutoScaling Group CPU utilization high threshold percent"
}

variable "cpu_utilization_low_threshold_percent" {
  type        = number
  description = "Worker nodes AutoScaling Group CPU utilization low threshold percent"
}

variable "map_additional_aws_accounts" {
  description = "Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_additional_iam_users" {
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "kubeconfig_path" {
  type        = string
  description = "The path to `kubeconfig` file"
}

variable "stage" {
  type        = string
  description = "Stage Eg: `dev`"
}

variable "ttl" {
  type        = string
  description = "TTL (in seconds) for the record"
}

variable "bastion_instance_type" {
  type        = string
  description = "Instance type of bastion hosts"
  default     = "t2.micro"
}


variable "number_nodes" {
  type        = string
  description = "(Required for Cluster Mode Disabled) The number of cache clusters (primary and replicas) this replication group will have. If Multi-AZ is enabled, the value of this parameter must be at least 2."
  default     = 3
}

variable "image_id" {
  type        = string
  description = "EC2 image ID to launch. If not provided, the module will lookup the most recent EKS AMI. See https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html for more details on EKS-optimized images"
  default     = ""
}

variable "use_custom_image_id" {
  type        = bool
  description = "If set to `true`, will use variable `image_id` for the EKS workers inside autoscaling group"
  default     = false
}

variable "ami_id" {
  type        = string
  description = "AMI ID of instance"
  default     = ""
}
