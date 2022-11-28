resource "kubernetes_deployment" "ebs_csi_controller" {

    metadata {

        name      = var.name
        namespace = var.namespace

        annotations = {

            "prometheus.io/port"   = "8080"
            "prometheus.io/scrape" = "false"

        }

        labels = {

            app = var.name

        }

    }

    spec {

        replicas = 1

        selector {

            match_labels = {

                app = var.name

            }

        }

        template {

            metadata {

                labels = {

                    app = var.name

                }

            }

            spec {

                node_selector = var.node_selector

                service_account_name            = kubernetes_service_account.csi.metadata[ 0 ].name
                automount_service_account_token = true
                priority_class_name             = "system-cluster-critical"

                toleration {

                    key      = "node-role.kubernetes.io/master"
                    operator = "Exists"
                    effect   = "NoSchedule"

                }

                container {

                    name  = "plugin"
                    image = var.image
                    args  = [

                        "controller",
                        "--endpoint=$(CSI_ENDPOINT)",
                        "--http-endpoint=:8080",
                        "--logtostderr"

                    ]

                    env {

                        name  = "CSI_ENDPOINT"
                        value = "unix:///var/lib/csi/sockets/pluginproxy/csi.sock"

                    }

                    env {

                        name = "CSI_NODE_NAME"

                        value_from {

                            field_ref {

                                field_path = "spec.nodeName"

                            }

                        }

                    }

                    env {

                        name = "AWS_EC2_ENDPOINT"

                        value_from {

                            config_map_key_ref {

                                name     = "aws-meta"
                                key      = "endpoint"
                                optional = true

                            }

                        }

                    }

                    volume_mount {

                        mount_path = "/var/lib/csi/sockets/pluginproxy/"
                        name       = "socket-dir"

                    }

                    port {

                        name           = "healthz"
                        container_port = 9808
                        protocol       = "TCP"

                    }

                    liveness_probe {

                        http_get {

                            path = "/healthz"
                            port = "healthz"

                        }

                        initial_delay_seconds = 10
                        timeout_seconds       = 3
                        period_seconds        = 10
                        failure_threshold     = 5
                    }

                    readiness_probe {

                        http_get {

                            path = "/healthz"
                            port = "healthz"

                        }

                        initial_delay_seconds = 10
                        timeout_seconds       = 3
                        period_seconds        = 10
                        failure_threshold     = 5

                    }

                }

                container {

                    name  = "csi-provisioner"
                    image = "k8s.gcr.io/sig-storage/csi-provisioner:v3.3.0"

                    args = [

                        "--csi-address=$(ADDRESS)",
                        "--feature-gates=Topology=true",
                        "--leader-election=true"

                    ]

                    env {

                        name  = "ADDRESS"
                        value = "/var/lib/csi/sockets/pluginproxy/csi.sock"

                    }

                    volume_mount {

                        mount_path = "/var/lib/csi/sockets/pluginproxy/"
                        name       = "socket-dir"

                    }

                }

                container {

                    name  = "csi-attacher"
                    image = "k8s.gcr.io/sig-storage/csi-attacher:v3.5.0"

                    args = [

                        "--csi-address=$(ADDRESS)",
                        "--leader-election=true",

                    ]

                    env {

                        name  = "ADDRESS"
                        value = "/var/lib/csi/sockets/pluginproxy/csi.sock"

                    }

                    volume_mount {

                        mount_path = "/var/lib/csi/sockets/pluginproxy/"
                        name       = "socket-dir"

                    }

                }

                container {

                    name  = "liveness-probe"
                    image = "k8s.gcr.io/sig-storage/livenessprobe:v2.8.0"

                    args = [

                        "--csi-address=/csi/csi.sock"

                    ]

                    volume_mount {

                        mount_path = "/csi"
                        name       = "socket-dir"

                    }

                }

                #
                #                dynamic "container" {
                #
                #                    for_each = local.resizer_container
                #
                #                    content {
                #
                #                        name  = lookup(container.value, "name", null)
                #                        image = lookup(container.value, "image", null)
                #
                #                        args = [
                #
                #                            "--csi-address=$(ADDRESS)",
                #                            "--handle-volume-inuse-error=false"
                #
                #                        ]
                #
                #                        env {
                #                            name  = "ADDRESS"
                #                            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
                #                        }
                #
                #                        volume_mount {
                #                            mount_path = "/var/lib/csi/sockets/pluginproxy/"
                #                            name       = "socket-dir"
                #                        }
                #                    }
                #                }
                #
                #                dynamic "container" {
                #                    for_each = local.snapshot_container
                #
                #                    content {
                #                        name  = lookup(container.value, "name", null)
                #                        image = lookup(container.value, "image", null)
                #
                #                        args = [
                #                            "--csi-address=$(ADDRESS)",
                #                            "--leader-election=true"
                #                        ]
                #
                #                        env {
                #                            name  = "ADDRESS"
                #                            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
                #                        }
                #
                #                        volume_mount {
                #                            mount_path = "/var/lib/csi/sockets/pluginproxy/"
                #                            name       = "socket-dir"
                #                        }
                #                    }
                #                }

                volume {

                    name = "socket-dir"
                    empty_dir {}

                }

            }

        }

    }

    #
    #    depends_on = [
    #        kubernetes_cluster_role_binding.attacher,
    #        kubernetes_cluster_role_binding.provisioner,
    #        kubernetes_csi_driver_v1.ebs,
    #    ]

}
