# IAM Policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.app_name}-s3-access-policy"
  description = "Policy to allow EKS access to S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = ["arn:aws:s3:::${aws_s3_bucket.app_bucket.bucket}"]
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = ["arn:aws:s3:::${aws_s3_bucket.app_bucket.bucket}/*"]
      }
    ]
  })
}


# IAM Role for EKS Worker Node S3 Access (created only if it doesn't exist)
resource "aws_iam_role" "eks_s3_worker_node_role" {
  name = "${var.app_name}-eks-s3-worker-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.app_name}-eks-s3-worker-node-role"
  }
}

# Attach the S3 access policy to the existing role
resource "aws_iam_role_policy_attachment" "eks_worker_node_s3_access" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.eks_s3_worker_node_role.name
}

# Additional IAM Policy Attachments for Worker Node
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_s3_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_s3_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_s3_worker_node_role.name
}
