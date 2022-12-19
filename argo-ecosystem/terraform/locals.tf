locals {
    kubeconfig= {

        path = "~/.kube/config"
        context = "k3d-cloudnative-tools-testing"
    }
}