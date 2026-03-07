########################################################################################################################
## Creates ECS Service
########################################################################################################################

resource "aws_ecs_service" "service" {
  name                               = "${var.project}_ECS_Service_${var.environment}"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.formbricks.arn
  desired_count                      = var.ecs_task_desired_count
  deployment_minimum_healthy_percent = var.ecs_task_deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.ecs_task_deployment_maximum_percent
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = 300

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_container_instance.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

}

output "service_name" {
  value = aws_ecs_service.service.name
}