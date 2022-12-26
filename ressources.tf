# Créer un nouveau bucket cloud storage dans le GCS. Une fois créé, sa localisation ne peut etre modifiée. Le bucket permet de stocker le site web (fichiers html, css, ...)
resource "google_storage_bucket" "portfolio" {
  # Le provider utilisé pour créer la ressource
  provider = google
  # Le nom du bucket sur le GCP - doit etre unique
  name     = var.portfolio
  # Location du Bucket - les valeurs possibles sont US ou EU
  location = "EU"

website {
# Rediriger automatiquement le DNS vers la homepage
  main_page_suffix = "index.html"
# Rediriger les liens des pages inexistantes vers la homepage
  not_found_page = "index.html"
}
}

# Permet de gérer les listes de control d'accès au bucket (ACL) who & how - ici, accès public
resource "google_storage_default_object_access_control" "portfolio_public" {
  bucket = google_storage_bucket.portfolio.name
  role   = "READER"
  entity = "allUsers"
}

# Réserver une adresse IP externe statique (VPC Network section on GCP)
resource "google_compute_global_address" "portfolio" {
  provider = google
  name     = var.portfolio
}

# Récupérer la zone DNS hébergée par le service Cloud DNS de GCP
data "google_dns_managed_zone" "portfolio" {
  provider = google
  name     = local.google_dns_managed_zone_name
}

# Ajouter l'IP au DNS 
resource "google_dns_record_set" "portfolio" {
  provider     = google
  name         = local.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.portfolio.name
  rrdatas      = [google_compute_global_address.portfolio.address]
}

# Créer un CDN backend et un Load Balancer de type HTTPS. Et relier ce dernier au bucket du GCS
resource "google_compute_backend_bucket" "portfolio" {
  provider    = google
  name        = var.portfolio
  description = "Contains files needed by the website"
  bucket_name = google_storage_bucket.portfolio.name
  enable_cdn  = true
}

# Créer un certificat HTTPS
resource "google_compute_managed_ssl_certificate" "portfolio" {
  provider = google-beta
  name     = var.portfolio
  managed {
    domains = [google_dns_record_set.portfolio.name]
  }
}

# Créer un Load Balancer de type HTTPS - 
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
# quelle ressource nous a permis de creer un lb dans ce code ? google_compute_backend_bucket ?

# GCP URL MAP : Rediriger les requetes vers le CDN backend 
resource "google_compute_url_map" "portfolio" {
  provider        = google
  name            = var.portfolio
  default_service = google_compute_backend_bucket.portfolio.self_link
}

# GCP target proxy : Utilisé par une ou plusieurs global forwarding rules pour acheminer les requêtes HTTPS entrantes vers l'URL map.
resource "google_compute_target_https_proxy" "portfolio" {
  provider         = google
  name             = var.portfolio
  url_map          = google_compute_url_map.portfolio.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.portfolio.self_link]
}

# GCP forwarding rule : Utilisé uniquement pour les LB. Permet de transférer le trafic vers le bon Load Balancer.
resource "google_compute_global_forwarding_rule" "portfolio" {
  provider              = google
  name                  = var.portfolio
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.portfolio.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.portfolio.self_link
}

terraform {
    backend "gcs" {
    bucket  = "portfolio-lab"
    prefix  = "terraform/state"
     }
    }