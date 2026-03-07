########################################################################################################################
## Creates an ECS Cluster
########################################################################################################################

resource "aws_ecs_cluster" "main" {
  name = "${var.project}_ECS_Cluster_${var.environment}"
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}