resource "helm_release" "argocd" {
    name = "argocd"

    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"
    version = "5.16.1"

    namespace = "argocd"
    create_namespace = true

    provisioner "local-exec" {
        command = <<EOF

            kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

        EOF
    }
}

// TODO: use traefik ingress for complete automation