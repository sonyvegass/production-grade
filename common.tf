# GCP provider
# il existe plusieurs cloud providers (gcp, aws, azure, ...). Ils permettent d'intéragir avec les ressources que l'on va créer
provider "google" {
  project      = var.gcp_project
  region       = var.gcp_region
}

# GCP beta provider
# celui-ci sera nécessaire pour créer le certificat SSL
provider "google-beta" {
  project      = var.gcp_project
  region       = var.gcp_region
}