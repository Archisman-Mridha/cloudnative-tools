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

resource "null_resource" "agro-workflows-installation" {

    provisioner "local-exec" {
        when = create

        command = <<EOF
            kubectl create namespace argo
            kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.4.3/install.yaml

            kubectl patch deployment \
                argo-server \
                --namespace argo \
                --type='json' \
                -p='[{"op": "replace",
                    "path": "/spec/template/spec/containers/0/args", "value": [
                        "server",
                        "--auth-mode=server"
                    ]
                }]'

            kubectl wait deployment -n argo argo-server --for condition=Available=True --timeout=180s
        EOF
    }

    provisioner "local-exec" {
        when = destroy

        command = <<EOF
            kubectl delete -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.4.3/install.yaml
            kubectl delete namespace argo
        EOF
    }
}

// TODO: use traefik ingress for complete automation

resource "null_resource" "argocd_server_password_output_as_file" {
    depends_on = [ helm_release.argocd ]

    provisioner "local-exec" {
        command = <<EOF

            #! disbale port-forwarding once you are done
            # kubectl port-forward svc/argocd-server -n argocd 8080:443 &

            # kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d \
            #    >> argocd-server-password.txt

        EOF
    }
}