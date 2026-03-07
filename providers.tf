########################################################################################################################
# AWS provider setup
########################################################################################################################

terraform {
  # Uncomment and configure the block below to use Terraform Cloud for remote state mgmt.
  #  cloud {
  #  organization = "your-organization"
  #  workspaces {
  #    name = "your-workspace"
  #  }
  #}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.31.0"
    }
    # Provider used to generate application secrets for Formbricks.
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      terraform   = "true"
      project     = var.project
      environment = var.environment
    }
  }
}

# CloudFront requires ACM certificates to be provisioned in us-east-1, regardless of the region
# the rest of the infrastructure is deployed to. This aliased provider ensures the CloudFront
# certificate is always created in us-east-1.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      terraform   = "true"
      project     = var.project
      environment = var.environment
    }
  }
}