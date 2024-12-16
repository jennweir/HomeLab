locals {
    K8S_NAMESPACE_CERT_MAN = "cert-manager"
    K8S_SERVICE_ACCOUNT_CERT_MAN = "cert-manager"
}

data "google_project" "pi_cluster" {
    project_id = "pi-cluster-433101"
}

resource "google_storage_bucket" "pi_homelab_bucket" {
    project = data.google_project.pi_cluster.project_id
    name = "pi-cluster"
    location = "US"
    force_destroy = true
    public_access_prevention = "inherited"
    uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "pi_homelab_bucket" {
    bucket = google_storage_bucket.pi_homelab_bucket.name
    role   = "roles/storage.objectViewer"
    member = "allUsers"
}

resource "google_iam_workload_identity_pool" "pi_cluster" {
    project                   = data.google_project.pi_cluster.project_id
    workload_identity_pool_id = "pi-cluster"
    display_name              = "pi-cluster"
    description               = "created with terraform"
}

resource "google_iam_workload_identity_pool_provider" "pi_cluster" {
    project = data.google_project.pi_cluster.project_id
    display_name                       = "pi-cluster"
    description                        = "created with terraform"
    workload_identity_pool_id          = google_iam_workload_identity_pool.pi_cluster.workload_identity_pool_id
    workload_identity_pool_provider_id = "pi-cluster"
    attribute_mapping = {
        "google.subject" = "assertion.sub"
    }
    oidc {
        issuer_uri        = "https://storage.googleapis.com/pi-cluster"
        allowed_audiences = [
        "//iam.googleapis.com/projects/${data.google_project.pi_cluster.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pi_cluster.workload_identity_pool_id}/providers/pi-cluster",
        ]
    }
}

resource "google_service_account" "dns_solver" {
    account_id   = "cert-manager-dns-solver-sa"
    display_name = "Cert Manager DNS Solver"
}

resource "google_project_iam_member" "dns_solver_dns_admin" {
    project = data.google_project.pi_cluster.project_id
    role    = "roles/dns.admin"
    member  = "serviceAccount:${google_service_account.dns_solver.email}" # cert-manager-dns-solver-sa@pi-cluster-433101.iam.gserviceaccount.com
}

# k8s service account cert-manager to google service account cert-manager-dns-solver-sa
resource "google_service_account_iam_member" "cert_manager_binding" {
    service_account_id = google_service_account.dns_solver.id
    role               = "roles/iam.workloadIdentityUser"
    member             = "principal://iam.googleapis.com/projects/${data.google_project.pi_cluster.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pi_cluster.workload_identity_pool_id}/subject/${local.K8S_NAMESPACE_CERT_MAN}/${local.K8S_SERVICE_ACCOUNT_CERT_MAN}"
}