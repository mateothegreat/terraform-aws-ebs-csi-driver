resource "kubernetes_service_account" "csi" {

    automount_service_account_token = true

    metadata {

        name      = var.name
        namespace = var.namespace

    }

}
