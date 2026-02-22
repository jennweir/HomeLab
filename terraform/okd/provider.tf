provider "google" {
  project = var.homelab_project_id
  region  = "us-east1"
}

provider "azuread" {
  tenant_id = var.azure_tenant_id
}