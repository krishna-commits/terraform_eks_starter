# provider "aws" {
#   region = var.region
#   version = "~> v2.0"
# }

provider "aws" {
  alias  = "North-California"
  region = "us-west-1"
}
