terraform {
    required_providers {

        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "2.16.1"
        }

        helm = {
            source = "hashicorp/helm"
            version = "2.7.1"
        }

    }
}

provider "kubernetes" {

    config_path = "~/.kube/config"
    config_context = "k3d-cloudnative-tools-testing"
}

provider "helm" {

    kubernetes {

        config_path = "~/.kube/config"
        config_context = "k3d-cloudnative-tools-testing"
    }
}