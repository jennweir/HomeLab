locals {
    wif_pool = "okd-pool"
    wif_provider = "okd-provider"
    smoke_tests_ns = "smoke-tests"
    smoke_tests_sa = "smoke-tests-sa"
    cert_manager_ns = "cert-manager"
    cert_manager_sa = "cert-manager"
    openshift_monitoring_ns = "openshift-monitoring"
    eso_sa = "external-secrets"
    eso_secrets = ["alertmanager-discord-config", "okd-cluster-cert-manager-cloudflare-api-token"]
}

data "google_project" "okd_homelab" {
    project_id = "okd-homelab"
}

resource "google_project_service" "wif" {
    project            = "${data.google_project.okd_homelab.project_id}"
    service            = "sts.googleapis.com"
    disable_on_destroy = false
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

resource "google_iam_workload_identity_pool" "okd_pool" {
    project                   = data.google_project.okd_homelab.project_id
    workload_identity_pool_id = local.wif_pool
    display_name              = local.wif_pool
    description               = "created with terraform"
}

resource "google_iam_workload_identity_pool_provider" "okd_provider" {
    project = data.google_project.okd_homelab.project_id
    display_name                       = local.wif_provider
    description                        = "created with terraform"
    workload_identity_pool_id          = google_iam_workload_identity_pool.okd_pool.workload_identity_pool_id
    workload_identity_pool_provider_id = local.wif_provider
    attribute_mapping = {
        "google.subject" = "assertion.sub"
    }
    oidc {
        issuer_uri        = "https://storage.googleapis.com/jennweir-homelab"
        allowed_audiences = [
            "//iam.googleapis.com/projects/${data.google_project.okd_homelab.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.okd_pool.workload_identity_pool_id}/providers/${local.wif_provider}", 
            "openshift"
        ]
    }
}

resource "google_service_account" "test_gsm_accessor" {
    account_id   = "test-gsm-accessor"
    display_name = "GSM Accessor Service Account for Testing"
    project      = data.google_project.okd_homelab.project_id
}

resource "google_secret_manager_secret_iam_member" "test_secret_access" {
    for_each  = toset(["test-secret"])
    project   = data.google_project.okd_homelab.project_id
    secret_id = each.value
    role      = "roles/secretmanager.secretAccessor"
    member    = "serviceAccount:${google_service_account.test_gsm_accessor.email}"
}

resource "google_service_account" "gsm_accessor" {
    account_id   = "gsm-accessor"
    display_name = "GSM Accessor Service Account"
    project      = data.google_project.okd_homelab.project_id
}

resource "google_secret_manager_secret_iam_member" "secrets_access" {
    for_each  = toset(local.eso_secrets)
    project   = data.google_project.okd_homelab.project_id
    secret_id = each.value
    role      = "roles/secretmanager.secretAccessor"
    member    = "serviceAccount:${google_service_account.gsm_accessor.email}"
}

resource "google_service_account_iam_member" "smoke_tests_wif_binding" {
    service_account_id = "projects/${data.google_project.okd_homelab.project_id}/serviceAccounts/${google_service_account.test_gsm_accessor.email}"
    role               = "roles/iam.workloadIdentityUser"
    member             = "principal://iam.googleapis.com/projects/${data.google_project.okd_homelab.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.okd_pool.workload_identity_pool_id}/subject/system:serviceaccount:${local.smoke_tests_ns}:${local.smoke_tests_sa}"
}

resource "google_service_account_iam_member" "cert_man_wif_binding" {
    service_account_id = "projects/${data.google_project.okd_homelab.project_id}/serviceAccounts/${google_service_account.gsm_accessor.email}"
    role               = "roles/iam.workloadIdentityUser"
    member             = "principal://iam.googleapis.com/projects/${data.google_project.okd_homelab.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.okd_pool.workload_identity_pool_id}/subject/system:serviceaccount:${local.cert_manager_ns}:${local.cert_manager_sa}"
}

resource "google_service_account_iam_member" "openshift_monitoring_wif_binding" {
    service_account_id = "projects/${data.google_project.okd_homelab.project_id}/serviceAccounts/${google_service_account.gsm_accessor.email}"
    role               = "roles/iam.workloadIdentityUser"
    member             = "principal://iam.googleapis.com/projects/${data.google_project.okd_homelab.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.okd_pool.workload_identity_pool_id}/subject/system:serviceaccount:${local.openshift_monitoring_ns}:${local.eso_sa}"
}
