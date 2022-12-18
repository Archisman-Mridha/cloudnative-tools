//* installing traefik using helm
resource "helm_release" "traefik" {
    depends_on = [ helm_release.argocd ]

    name = "traefik"

    repository = "https://traefik.github.io/charts"
    chart = "traefik"
    version = "20.8.0"

    namespace = "traefik"
    create_namespace = true
}