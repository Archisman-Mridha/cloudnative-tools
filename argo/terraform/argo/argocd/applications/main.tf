terraform {

    required_providers {

        argocd = {
            source = "oboukili/argocd"
            version = "4.1.0"
        }
    }
}

provider "argocd" {
    server_addr = "localhost:8080"
    insecure = true

    username = "admin"
    password = file("../installation/argocd-server-password.txt")

    kubernetes {

        config_path = "~/.kube/config"
        config_context = "k3d-cloudnative-testing-tools"
    }
}