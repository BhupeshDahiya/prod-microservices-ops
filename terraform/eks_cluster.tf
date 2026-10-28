resource "aws_eks_cluster" "main_cluster" {
  name = var.cluster_name

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  role_arn = aws_iam_role.cluster_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = [for subnet in aws_subnet.pvt_sub : subnet.id]
  }

  # Enable EKS control plane logging for visibility and debugging
  enabled_cluster_log_types = [
    "api",               # API server audit logs
    "audit",             # Kubernetes audit logs
    "authenticator",     # Authenticator logs for IAM auth
    "controllerManager", # Logs for controller manager
    "scheduler"          # Logs for pod scheduling
  ]

  tags = var.tags

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_eks_access_entry" "vpro_access" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  principal_arn = var.principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "vpro_access" {
  cluster_name  = aws_eks_cluster.main_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.principal_arn

  access_scope {
    type = "cluster"
  }
  depends_on = [aws_eks_access_entry.vpro_access] # the access entry must exist before we can associate as policy to it
}
