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

resource "null_resource" "argocd_server_password_output_as_file" {
    depends_on = [ helm_release.argocd ]

    provisioner "local-exec" {
        command = <<EOF

            #! disbale port-forwarding once you are done
            kubectl port-forward svc/argocd-server -n argocd 8080:443 &

            kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d \
               >> argocd-server-password.txt

        EOF
    }
}