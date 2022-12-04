terraform {
    required_providers {

        helm = {
            source = "hashicorp/helm"
            version = "2.7.1"
        }

    }
}

provider "helm" {

    kubernetes {

        config_path = "~/.kube/config"
        config_context = "k3d-cloudnative-tools-testing"
    }
}