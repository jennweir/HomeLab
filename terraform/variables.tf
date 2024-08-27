variable "project_id" {
    description = "ID of project where the IAM policy binding will be applied"
    type        = string
    default     = "pi-cluster-433101"
}

variable "project_number" {
    description = "Number of project where the IAM policy binding will be applied"
    type        = string
    default     = "494599251997"
}

variable "namespace" {
    description = "Kubernetes namespace where the service account exists"
    type        = string
    default     = "default"
}
