terraform { 
  cloud { 
    organization = "jennweir-org" 
    workspaces { 
      name = "homelab" 
    } 
  } 
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.42.0"
    }
  }
  required_version = ">= 1.1.2"
}
