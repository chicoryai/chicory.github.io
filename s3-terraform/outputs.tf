output "s3_bucket_name" {
  value = aws_s3_bucket.app_bucket.bucket
}

output "iam_role_for_s3_access" {
  value = aws_iam_role.eks_s3_worker_node_role.arn
}
