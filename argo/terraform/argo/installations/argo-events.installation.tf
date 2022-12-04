resource "null_resource" "agro_workflows_installation" {

    provisioner "local-exec" {
        when = create

        command = <<EOF
            kubectl create namespace argo-events
        EOF
    }

    provisioner "local-exec" {
        when = destroy

        command = <<EOF
            kubectl delete namespace argo-events
        EOF
    }
}