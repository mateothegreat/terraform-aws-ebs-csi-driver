variable "name" {

    type        = string
    description = "Name of the resource group to create."
    default     = "csi"

}

variable "namespace" {

    type        = string
    description = "Namespace to deploy the CSI driver to."
    default     = "kube-system"

}

variable "node_selector" {

    type        = map(string)
    description = "Node selector for the CSI driver."
    default     = null

}

variable "image" {

    type        = string
    description = "The image to use for the CSI driver."
    default     = "k8s.gcr.io/provider-aws/aws-ebs-csi-driver:v1.13.0"

}
