provider "aws" {
  region  = var.cluster_region
  profile = var.aws_profile

  default_tags {
    tags = var.aws_provider_default_tags
  }
}

provider "helm" {
  kubernetes {
    host                   = module.aws.cluster_endpoint
    cluster_ca_certificate = module.aws.cluster_ca_certificate
    token                  = module.aws.cluster_token
  }
}
