resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-default-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = data.aws_subnet_ids.private.ids
  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }
  instance_types = [
    var.node_instance_type
  ]
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy
  ]
  tags = {
    Name = "${var.cluster_name}-default-node-group"
  }
}


# Additional node group with t3.small instances for SumoLogic
resource "aws_eks_node_group" "sumologic-eks-node-group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-sumologic-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = data.aws_subnet_ids.private.ids
  scaling_config {
    desired_size = var.sumo_node_desired_capacity
    max_size     = var.sumo_node_max_size
    min_size     = var.sumo_node_min_size
  }
  instance_types = [
    var.sumo_node_instance_type
  ]
  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy
  ]
  tags = {
    Name = "${var.cluster_name}-sumologic-node-group"
  }
}
