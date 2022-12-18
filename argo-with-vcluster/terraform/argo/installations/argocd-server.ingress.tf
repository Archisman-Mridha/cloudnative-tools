//* exposing argoCD server using Kubernetes ingress

data "kubectl_file_documents" "file_documents" {
    content = file("./manifests/argocd-server.ingress.yaml")
}

resource "kubectl_manifest" "ingress" {
    depends_on = [ helm_release.traefik ]

    for_each = data.kubectl_file_documents.file_documents.manifests
    yaml_body = each.value
}