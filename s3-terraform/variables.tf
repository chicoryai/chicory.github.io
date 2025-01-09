variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "chicory-agent-api"
}

variable "eks_cluster_name" {
  description = "Name of the existing EKS cluster"
  type        = string
}
