module "label" {
  source = "../../modules/label"

  enabled    = var.enabled
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

resource "aws_secretsmanager_secret" "secret_key" {
  count       = var.enabled ? 1 : 0
  name        = module.label.id
  description = var.description
  tags = merge(
    module.label.tags,
    map(
      "Name", "${module.label.id}-key"
    )
  )

}

resource "aws_secretsmanager_secret_version" "secret_key_value" {
  count         = var.enabled ? 1 : 0
  secret_id     = join("", aws_secretsmanager_secret.secret_key.*.id)
  secret_string = var.secret_string
}

