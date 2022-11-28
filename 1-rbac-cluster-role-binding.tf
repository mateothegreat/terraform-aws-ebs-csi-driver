resource "kubernetes_cluster_role_binding" "csi" {

    metadata {

        name = "ebs-csi-node-getter-binding"

    }

    role_ref {

        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = kubernetes_cluster_role.csi.metadata[ 0 ].name

    }

    subject {

        kind      = "ServiceAccount"
        name      = kubernetes_service_account.csi.metadata[ 0 ].name
        namespace = kubernetes_service_account.csi.metadata[ 0 ].namespace

    }

}
