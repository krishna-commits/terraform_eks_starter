terraform {
  required_version = "~> 0.14.3"
  # Lock down on the versions
  required_providers {
    aws        = "~> 2.0"
    template   = "~> 2.0"
    null       = "~> 2.0"
    local      = "~> 1.3"
    kubernetes = "~> 1.9"
    tls        = "~> 2.1"
  }
  # required_providers {
  #   aws = {
  #     source  = "hashicorp/aws"
  #     version = ">= 3.20.0"
  #   }

  #   random = {
  #     source  = "hashicorp/random"
  #     version = "3.0.0"
  #   }

  #   local = {
  #     source  = "hashicorp/local"
  #     version = "2.0.0"
  #   }

  #   null = {
  #     source  = "hashicorp/null"
  #     version = "3.0.0"
  #   }

  #   template = {
  #     source  = "hashicorp/template"
  #     version = "2.2.0"
  #   }

  #   kubernetes = {
  #     source  = "hashicorp/kubernetes"
  #     version = ">= 2.0.1"
  #   }
  # }

#   required_version = "> 0.14"
# }
  # This sets up the remote backend in terraform cloud mainly with two workspaces
  # `dev` and `prod`.
  # Workspace provides us the way to maintain multiple terraform states in remote
  # backend. It also provides a global name `terraform.workspace` that might be able to
  # differentiate resource in aws based on environment or workspace we are in.
  backend "remote" {
    hostname = "app.terraform.io"
    # This needs to replaced by the organization that you create in terraform.io
    organization = "testtome"
    # For multiple workspace support
    workspaces {
      prefix = "infrastructure-"
    }
  }
}
