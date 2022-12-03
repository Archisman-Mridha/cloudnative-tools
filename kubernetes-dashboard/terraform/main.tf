terraform {
    backend "local" { }

    required_providers {

        helm = {
            source = "hashicorp/helm"
            version = "2.7.1"
        }

        kubectl = {
            source = "gavinbunney/kubectl"
            version = "1.14.0"
        }

    }
}

provider "helm" {

    kubernetes {

        config_path = "~/.kube/config"
        config_context = "k3d-cloudnative-tools-testing"
    }
}

provider "kubectl" {
    load_config_file = true

    config_context = "k3d-cloudnative-tools-testing"
}