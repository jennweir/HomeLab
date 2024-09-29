locals {
    K8S_NAMESPACE = "kubernetes-dashboard"
    K8S_SERVICE_ACCOUNT = "kubernetes-dashboard"
    K8S_GCP_PROJECT_NUMBER = "494599251997"
    K8S_WORKLOAD_IDENTITY_POOL = "k8s-wif-pool"
}

# GCP service account that the kubernetes service account impersonates
# can create it via Terraform pipeline
resource "google_service_account" "gcp_wif_service_account" {
    account_id   = "gcp-wif-service-account"
    display_name = "GCP WIF Service Account"
    project      = "pi-cluster-433101" # project id
}

# GCP policy WIF binding: what allows our k8s service account to impersonate GCP service account
resource "google_service_account_iam_member" "kubernetes-dashboard" {
    service_account_id = google_service_account.gcp_wif_service_account.name
    role               = "roles/iam.workloadIdentityUser"
    # principal://iam.googleapis.com/projects/494599251997/locations/global/workloadIdentityPools/k8s-wif-pool/subject/SUBJECT_ATTRIBUTE_VALUE (subject of OIDC token)
    member             = "principal://iam.googleapis.com/projects/${local.K8S_GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${local.K8S_WORKLOAD_IDENTITY_POOL}/subject/${local.K8S_NAMESPACE}/${local.K8S_SERVICE_ACCOUNT}"
}