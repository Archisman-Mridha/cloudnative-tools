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