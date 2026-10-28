resource "aws_eks_node_group" "main_cluster_node_group" {
  cluster_name         = aws_eks_cluster.main_cluster.name # didnt use var so as to create a direct dependency on cluster so that cluster is created first and then nodes are created
  node_group_name      = var.node_group_name
  node_role_arn        = aws_iam_role.node_group_role.arn
  subnet_ids           = [for subnet in aws_subnet.pvt_sub : subnet.id]
  capacity_type        = var.capacity_type
  instance_types       = var.instance_types
  ami_type             = var.ami_type
  disk_size            = var.disk_size
  force_update_version = true

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable_percentage = 50
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]

  labels = {
    "env" = var.environment_name
  }

  # Tags for the node group and associated EC2 instances
  tags = merge(var.tags, {
    # Standard EC2 name tag
    Name = "${var.node_group_name}-private-ng"

    # Logical environment (e.g., dev, prod)
    Environment = var.environment_name
  })
}
