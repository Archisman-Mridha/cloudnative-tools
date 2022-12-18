terraform {
    required_providers {

        kubectl = {
            source = "gavinbunney/kubectl"
            version = "1.14.0"
        }

        helm = {
            source = "hashicorp/helm"
            version = "2.7.1"
        }

    }
}

provider "kubectl" {
    config_path = local.kubeconfig_details.path
    config_context = local.kubeconfig_details.context
}

provider "helm" {

    kubernetes {

        config_path = local.kubeconfig_details.path
        config_context = local.kubeconfig_details.context
    }
}