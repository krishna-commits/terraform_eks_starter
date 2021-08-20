module "label" {
  source     = "../label"
  namespace  = var.namespace
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

resource "aws_ecr_repository" "default" {
  name                 = module.label.id
  tags                 = module.label.tags
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
