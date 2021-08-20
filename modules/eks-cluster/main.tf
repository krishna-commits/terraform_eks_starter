module "label" {
  source     = "../label"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, ["cluster"]))
  tags       = var.tags
  enabled    = var.enabled
}

# The EKS service does not provide a cluster-level API parameter or resource to automatically configure the underlying Kubernetes cluster
# to allow worker nodes to join the cluster via AWS IAM role authentication.

# NOTE: To automatically apply the Kubernetes configuration to the cluster (which allows the worker nodes to join the cluster),
# the requirements outlined here must be met:
# https://learn.hashicorp.com/terraform/aws/eks-intro#preparation
# https://learn.hashicorp.com/terraform/aws/eks-intro#configuring-kubectl-for-eks
# https://learn.hashicorp.com/terraform/aws/eks-intro#required-kubernetes-configuration-to-join-worker-nodes

# Additional links
# https://learn.hashicorp.com/terraform/aws/eks-intro
# https://itnext.io/how-does-client-authentication-work-on-amazon-eks-c4f2b90d943b
# https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
# https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
# https://docs.aws.amazon.com/cli/latest/reference/eks/update-kubeconfig.html
# https://docs.aws.amazon.com/en_pv/eks/latest/userguide/create-kubeconfig.html
# https://itnext.io/kubernetes-authorization-via-open-policy-agent-a9455d9d5ceb
# http://marcinkaszynski.com/2018/07/12/eks-auth.html
# https://cloud.google.com/kubernetes-engine/docs/concepts/configmap
# http://yaml-multiline.info
# https://github.com/terraform-providers/terraform-provider-kubernetes/issues/216


locals {
  certificate_authority_data_list          = coalescelist(aws_eks_cluster.default.*.certificate_authority, [[{ data : "" }]])
  certificate_authority_data_list_internal = local.certificate_authority_data_list[0]
  certificate_authority_data_map           = local.certificate_authority_data_list_internal[0]
  certificate_authority_data               = local.certificate_authority_data_map["data"]

  configmap_auth_template_file = join("/", [path.root, "addons", "configmap-auth.yaml.tpl"])
  configmap_auth_file          = join("/", [path.module, "configmap-auth.yaml"])

  ingress_controller_template_file = "${path.root}/addons/ingress-controller.yaml.tpl"
  ingress_controller_file          = "${path.module}/ingress-controller.yaml"

  external_dns_template_file = join("/", [path.root, "addons", "external-dns.yaml.tpl"])
  external_dns_file          = join("/", [path.module, "external-dns.yaml"])

  cluster_name = join("", aws_eks_cluster.default.*.id)

  # Add worker nodes role ARNs (could be from many worker groups) to the ConfigMap
  map_worker_roles = [
    for role_arn in var.workers_role_arns : {
      rolearn : role_arn
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]

  map_bastion_host_roles = [
    for role_arn in var.bastion_host_role_arns : {
      rolearn : role_arn
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:masters"
      ]
    }
  ]

  map_bastion_host_roles_yaml      = trimspace(yamlencode(local.map_bastion_host_roles))
  map_worker_roles_yaml            = trimspace(yamlencode(local.map_worker_roles))
  map_additional_iam_roles_yaml    = trimspace(yamlencode(var.map_additional_iam_roles))
  map_additional_iam_users_yaml    = trimspace(yamlencode(var.map_additional_iam_users))
  map_additional_aws_accounts_yaml = trimspace(yamlencode(var.map_additional_aws_accounts))
}

data "template_file" "configmap_auth" {
  count    = var.enabled && var.apply_config_map_aws_auth ? 1 : 0
  template = file(local.configmap_auth_template_file)

  vars = {
    map_worker_roles_yaml            = local.map_worker_roles_yaml
    map_additional_iam_roles_yaml    = local.map_additional_iam_roles_yaml
    map_additional_iam_users_yaml    = local.map_additional_iam_users_yaml
    map_additional_aws_accounts_yaml = local.map_additional_aws_accounts_yaml
    map_bastion_host_roles_yaml      = local.map_bastion_host_roles_yaml
  }
}

resource "local_file" "configmap_auth" {
  count    = var.enabled && var.apply_config_map_aws_auth ? 1 : 0
  content  = join("", data.template_file.configmap_auth.*.rendered)
  filename = local.configmap_auth_file
}


data "template_file" "external_dns" {
  count    = var.enabled ? 1 : 0
  template = file(local.external_dns_template_file)
  vars = {
    cluster_id = local.cluster_name
  }
}

resource "local_file" "external_dns" {
  count    = var.enabled ? 1 : 0
  content  = join("", data.template_file.external_dns.*.rendered)
  filename = local.external_dns_file
}

data "template_file" "ingress_controller" {
  count    = var.enabled ? 1 : 0
  template = file(local.ingress_controller_template_file)

  vars = {
    eks_cluster_name = local.cluster_name
  }
}

resource "local_file" "ingress_controller" {
  count    = var.enabled ? 1 : 0
  content  = join("", data.template_file.ingress_controller.*.rendered)
  filename = local.ingress_controller_file
}


resource "null_resource" "eks_init_script" {
  count = var.enabled && var.apply_config_map_aws_auth ? 1 : 0

  triggers = {
    cluster_updated                 = join("", aws_eks_cluster.default.*.id)
    worker_roles_updated            = local.map_worker_roles_yaml
    additional_roles_updated        = local.map_additional_iam_roles_yaml
    additional_users_updated        = local.map_additional_iam_users_yaml
    additional_aws_accounts_updated = local.map_additional_aws_accounts_yaml
  }

  depends_on = [aws_eks_cluster.default, local_file.configmap_auth]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      while [[ ! -e ${local.configmap_auth_file} ]] ; do sleep 1; done && \
      aws eks update-kubeconfig --name=${local.cluster_name} --region=${var.region} --kubeconfig=${var.kubeconfig_path} && \
      kubectl apply -f ${local.configmap_auth_file} --kubeconfig ${var.kubeconfig_path}
      kubectl apply -f ${local.ingress_controller_file} --kubeconfig ${var.kubeconfig_path}
      kubectl apply -f ${local.external_dns_file} --kubeconfig ${var.kubeconfig_path}
    EOT
  }
}

data "aws_iam_policy_document" "assume_role" {
  count = var.enabled ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  count              = var.enabled ? 1 : 0
  name               = module.label.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
  tags               = module.label.tags
}


resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_service_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_security_group" "default" {
  count       = var.enabled ? 1 : 0
  name        = module.label.id
  description = "Security Group for EKS cluster"
  vpc_id      = var.vpc_id
  tags        = module.label.tags
}

resource "aws_security_group_rule" "egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "egress"
}


resource "aws_security_group_rule" "ingress_workers" {
  count                    = var.enabled ? var.workers_security_group_count : 0
  description              = "Allow the cluster to receive communication from the worker nodes"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = var.workers_security_group_ids[count.index]
  security_group_id        = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = var.enabled ? length(var.allowed_security_groups) : 0
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = var.allowed_security_groups[count.index]
  security_group_id        = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = var.enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "ingress"
}

resource "aws_eks_cluster" "default" {
  count                     = var.enabled ? 1 : 0
  name                      = module.label.id
  role_arn                  = join("", aws_iam_role.default.*.arn)
  version                   = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    security_group_ids      = [join("", aws_security_group.default.*.id)]
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy,
    aws_iam_role_policy_attachment.amazon_eks_service_policy
  ]
}
