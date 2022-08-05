output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller.arn
}

output "kube-system" {
  value = aws_eks_fargate_profile.kube-system.id
}

output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "certificate_authority" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "cluster_id" {
  value = aws_eks_cluster.cluster.id
}