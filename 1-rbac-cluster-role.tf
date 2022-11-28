resource "kubernetes_cluster_role" "csi" {

    metadata {

        name = "ebs-csi-node-role"

    }

    rule {

        api_groups = [ "" ]
        resources  = [ "nodes" ]
        verbs      = [ "get" ]

    }

}
