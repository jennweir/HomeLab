resource "google_service_account" "cert_manager_sa" {
    account_id   = "cert-manager-sa"
    display_name = "Service Account for cert-manager"
}

resource "google_project_iam_member" "dns_admin_binding" {
    project = "pi-cluster-433101"
    role    = "roles/dns.admin"
    member  = "serviceAccount:${google_service_account.cert_manager_sa.email}"
}

# resource "google_project_iam_binding" "workload_identity_user_binding" {
#     project = var.project_id
#     role    = "roles/iam.workloadIdentityUser"

#     members = [
#         "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.k8s_wif_pool.name}/attribute.actor/service-account/${var.namespace}/cert-manager"
#     ]
# }

resource "google_service_account_key" "cert_manager_key" {
    service_account_id = google_service_account.cert_manager_sa.email
    key_algorithm      = "KEY_ALG_RSA_2048"
}
