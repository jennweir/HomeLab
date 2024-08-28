variable "project_id" {
    description = "Google project id"
    type        = string
    default     = "pi-cluster-433101"
}

variable "project_number" {
    description = "Google project number"
    type        = string
    default     = "494599251997"
}

variable "namespace" {
    description = "Kubernetes namespace where the service account exists"
    type        = string
    default     = ""
}
