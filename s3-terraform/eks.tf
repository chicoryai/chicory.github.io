data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

resource "kubernetes_service_account" "s3_access_service_account" {
  metadata {
    name      = "s3-access-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_s3_worker_node_role.arn
    }
  }
}
