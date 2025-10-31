locals {
    wif_pool = "okd-pool"
    wif_provider = "okd-provider"
    eso_namespace = "external-secrets-operator"
    eso_sa = "external-secrets" 
}

data "google_project" "okd_homelab" {
    project_id = "okd-homelab"
}

resource "google_storage_bucket" "homelab_bucket" {
    project = data.google_project.okd_homelab.project_id
    name = "jennweir-homelab"
    location = "US"
    force_destroy = true
    public_access_prevention = "inherited"
    uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "homelab_bucket" {
    bucket = google_storage_bucket.homelab_bucket.name
    role   = "roles/storage.objectViewer"
    member = "allUsers"
}

resource "google_iam_workload_identity_pool" "okd_homelab" {
    project                   = data.google_project.okd_homelab.project_id
    workload_identity_pool_id = "okd-homelab"
    display_name              = "okd-homelab"
    description               = "created with terraform"
}

resource "google_iam_workload_identity_pool_provider" "okd_homelab" {
    project = data.google_project.okd_homelab.project_id
    display_name                       = "okd-homelab"
    description                        = "created with terraform"
    workload_identity_pool_id          = google_iam_workload_identity_pool.okd_homelab.workload_identity_pool_id
    workload_identity_pool_provider_id = "okd-homelab"
    attribute_mapping = {
        "google.subject" = "assertion.sub"
    }
    oidc {
        issuer_uri        = "https://storage.googleapis.com/jennweir-homelab"
        allowed_audiences = [
        "//iam.googleapis.com/projects/${data.google_project.okd_homelab.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.okd_homelab.workload_identity_pool_id}/providers/okd-homelab",
        ]
    }
}

resource "google_service_account" "sa_okd" {
    account_id   = "sa-okd"
    display_name = "sa-okd"
    project      = data.google_project.okd_homelab.project_id
}

resource "google_service_account_iam_member" "okd_wif" {
    service_account_id = "projects/${data.google_project.okd_homelab.project_id}/serviceAccounts/${google_service_account.sa_okd.email}"
    role               = "roles/iam.workloadIdentityUser"
    member             = "principal://iam.googleapis.com/projects/${data.google_project.okd_homelab.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.okd_homelab.workload_identity_pool_id}/subject/system:serviceaccount:${local.wif_provider}:${local.wif_pool}"
}

resource "google_service_account" "gsm_accessor" {
    account_id   = "gsm-accessor"
    display_name = "GSM Accessor Service Account"
    project      = data.google_project.okd_homelab.project_id
}

resource "google_project_iam_member" "gsm_accessor_role" {
    project = data.google_project.okd_homelab.project_id
    role    = "roles/secretmanager.secretAccessor"
    member  = "serviceAccount:${google_service_account.gsm_accessor.email}"
}

resource "google_service_account_iam_member" "eso_wif" {
    service_account_id = "projects/${data.google_project.okd_homelab.project_id}/serviceAccounts/${google_service_account.gsm_accessor.email}"
    role               = "roles/iam.workloadIdentityUser"
    member             = "principal://iam.googleapis.com/projects/${data.google_project.okd_homelab.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.okd_homelab.workload_identity_pool_id}/subject/system:serviceaccount:${local.eso_namespace}:${local.eso_sa}"
}