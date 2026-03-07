########################################################################################################################
## IAM Role for ECS Task execution
########################################################################################################################

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.project}_ECS_TaskExecutionRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json

}

data "aws_iam_policy_document" "task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

########################################################################################################################
## IAM Role for ECS Task
########################################################################################################################

resource "aws_iam_role" "ecs_task" {
  name               = "${var.project}_ECS_TaskIAMRole_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role_policy.json

}

########################################################################################################################
## IAM Policy for ECS Task role to access Secrets Manager
########################################################################################################################

resource "aws_iam_role_policy" "ecs_task_secrets" {
  name = "ecs-task-secrets-policy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "secretsmanager:GetSecretValue"
        Effect = "Allow"
        Resource = [
          aws_db_instance.formbricks.master_user_secret[0].secret_arn,
          aws_secretsmanager_secret.formbricks_url.arn,
          aws_secretsmanager_secret_version.formbricks_url_val.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_execution_secrets" {
  name = "ecs-execution-secrets-policy"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        Resource = [
          aws_secretsmanager_secret.formbricks_url.arn,
          aws_db_instance.formbricks.master_user_secret[0].secret_arn
        ]
      }
    ]
  })
}