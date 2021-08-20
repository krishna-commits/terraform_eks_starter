module "label" {
  source     = "../label"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, ["bastion"]))
  tags       = var.tags
  enabled    = var.enabled
}

locals {
  bastion_host_role_arn = join("", aws_iam_role.default.*.arn)
}



data "aws_ami" "default" {
  count = var.enabled && var.use_custom_image_id == false ? 1 : 0

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
  }


  owners = ["099720109477"] # Amazon
}

data "aws_iam_policy_document" "default" {
  count = var.enabled ? 1 : 0
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_instance_profile" "default" {
  count = var.enabled ? 1 : 0

  name = module.label.id
  role = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role" "default" {
  count = var.enabled ? 1 : 0

  name               = module.label.id
  path               = "/"
  assume_role_policy = join("", data.aws_iam_policy_document.default.*.json)
}


resource "aws_iam_role_policy_attachment" "bastion_eks_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "cloud_watch_agent_server_policy" {
  count      = var.enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_security_group" "default" {
  count = var.enabled ? 1 : 0

  name        = module.label.id
  vpc_id      = var.vpc_id
  description = "Bastion security group (only SSH inbound access is allowed)"

  tags = module.label.tags

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = var.destination_security_groups

  }
  lifecycle {
    create_before_destroy = true
  }
}



module "aws_ssh_bastion_key_pair" {
  source = "../../commons/ssh-key-pair"

  enabled   = var.enabled
  namespace = module.label.namespace
  stage     = module.label.stage
  name      = "bastion-key-pair"

  generate_ssh_key = true

  private_key_path = path.root
  public_key_path  = path.root

}

module "aws_bastion_secrets_manager" {
  source        = "../../commons/secrets-manager"
  enabled       = var.enabled
  namespace     = module.label.namespace
  stage         = module.label.stage
  name          = "bastion-key-pair"
  secret_string = module.aws_ssh_bastion_key_pair.private_key


}

data "template_file" "default" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/user_data.sh")

  vars = {
    user_data       = join("\n", var.user_data)
    welcome_message = var.stage
    ssh_user        = var.ssh_user
    cluster_name    = var.cluster_name
    region          = var.region
  }
}

resource "aws_launch_configuration" "default" {
  name_prefix = module.label.id
  image_id    = var.use_custom_image_id ? var.ami_id : join("", data.aws_ami.default.*.id)

  instance_type = var.instance_type

  key_name                    = module.aws_ssh_bastion_key_pair.key_name
  associate_public_ip_address = false
  security_groups             = [join("", aws_security_group.default.*.id)]
  iam_instance_profile        = join("", aws_iam_instance_profile.default.*.name)

  user_data = join("", data.template_file.default.*.rendered)


  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "default" {
  count               = var.enabled ? 1 : 0
  vpc_zone_identifier = var.subnet_ids


  name_prefix          = format("%s%s", module.label.id, var.delimiter)
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  launch_configuration = join("", aws_launch_configuration.default.*.name)


  tags = flatten([
    for key in keys(module.label.tags) :
    {
      key                 = key
      value               = module.label.tags[key]
      propagate_at_launch = true
    }
  ])

  lifecycle {
    create_before_destroy = true
  }
}
