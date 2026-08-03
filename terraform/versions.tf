terraform {
  required_version = ">= 1.7.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0" # pin/bump after checking the registry for the current major version
    }
  }

  # Remote state via HCP Terraform (Terraform Cloud) free tier — keeps state
  # out of this public repo. Create the org/workspace in HCP Terraform first,
  # then fill in the values below (or set TF_CLOUD_ORGANIZATION /
  # TF_WORKSPACE env vars in CI instead of hardcoding).
  cloud {
    organization = "oruganti"
    workspaces {
      name = "oruganti-dev-main"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
