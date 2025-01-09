module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"  # Ensure compatibility with your configuration
  cluster_name    = "${var.app_name}-cluster"
  cluster_version = "1.31"
  vpc_id          = aws_vpc.main.id
  subnets         = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  node_groups = {
    default = {
      name = "${var.app_name}-node-group"
      instance_type = var.node_group_instance_type
      desired_capacity = var.desired_node_count
      min_capacity = var.min_node_count
      max_capacity = var.max_node_count
      iam_role_arn = aws_iam_role.eks_worker_node_role.arn
    }
  }

  tags = {
    Environment = "production"
    Project     = var.app_name
  }
}
