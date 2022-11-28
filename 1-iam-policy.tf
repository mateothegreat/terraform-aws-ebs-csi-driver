resource "aws_iam_policy" "csi" {

    name_prefix = var.name
    policy      = file("${path.module}/1-iam-policy.json") #tfsec:ignore:aws-iam-no-policy-wildcards
    description = "Policy for EBS CSI driver"

}
