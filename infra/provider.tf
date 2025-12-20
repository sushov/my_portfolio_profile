#GCP provider


provider "google" {
    # credentials line is gone! It now uses your local gcloud login automatically.
    project = var.gcp_project
    region = var.gcp_region
}