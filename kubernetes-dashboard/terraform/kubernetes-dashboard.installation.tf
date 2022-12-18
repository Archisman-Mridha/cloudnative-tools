#* install kubernetes-dashboard helm charts
resource "helm_release" "kubernetes_dashboard" {
    name = "kubernetes-dashboard"

    namespace = "kubernetes-dashboard"
    create_namespace = true

    repository = "https://kubernetes.github.io/dashboard"
    chart = "kubernetes-dashboard"
    version = "6.0.0"

    values = ["dashboard.sessionTimeout: 14400"]
}

#* creating an admin service-account for monitoring everything

data "kubectl_path_documents" "admin_account_creation_documents" {
    pattern = "./manifests/*.yaml"
}

resource "kubectl_manifest" "admin_account_creation_manifest" {
    depends_on = [ helm_release.kubernetes_dashboard ]

    for_each = toset(data.kubectl_path_documents.admin_account_creation_documents.documents)
    yaml_body = each.value
}