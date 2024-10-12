locals {
    K8S_NAMESPACE_CERT_MAN = "cert-manager"
    K8S_SERVICE_ACCOUNT_CERT_MAN = "cert-manager"
    K8S_GCP_PROJECT_NUMBER = "494599251997"
    K8S_WORKLOAD_IDENTITY_POOL = "k8s-wif-pool"
}

# GCP service account that the kubernetes service account impersonates
# can create it via Terraform pipeline
resource "google_service_account_iam_member" "cert_manager_binding" {
    service_account_id = "projects/pi-cluster-433101/serviceAccounts/dns01-solver@pi-cluster-433101.iam.gserviceaccount.com"
    role               = "roles/iam.workloadIdentityUser"
    member             = "principal://iam.googleapis.com/projects/${local.K8S_GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${local.K8S_WORKLOAD_IDENTITY_POOL}/subject/${local.K8S_NAMESPACE_CERT_MAN}/${local.K8S_SERVICE_ACCOUNT_CERT_MAN}"
}