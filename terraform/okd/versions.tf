terraform { 
  backend "gcs" {
    bucket = "jennweir-homelab"
    prefix = "terraform/state/okd"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.42.0"
    }
  }
  required_version = ">= 1.1.2"
}
