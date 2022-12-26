# Créer des variables locales qui seront valides dans tous les workspaces
locals{
  google_dns_managed_zone_name = "lab-innovorder-dev"
  dns_name                     = "portfolio.${data.google_dns_managed_zone.portfolio.dns_name}"
}
