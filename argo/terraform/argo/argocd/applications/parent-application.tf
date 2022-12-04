resource "argocd_application" "parent" {

    metadata {
        name = "parent"
        namespace = "argocd"

        labels = {
            "app" = "argocd"
        }
    }

    spec {
        project = "default"

        source {

            repo_url = "https://github.com/Archisman-Mridha/cloudnative-tools"
            path = "argo/kubernetes/argo/cd"
            target_revision = "main" 
        }

        destination {

            server = "https://kubernetes.default.svc"
            namespace = "microservices"
        }

        sync_policy {

            automated = {
                prune = true
                self_heal = true
            }
        }
    }
}