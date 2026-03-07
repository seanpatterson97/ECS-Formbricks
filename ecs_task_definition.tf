# Generate encryption secrets necessary for Formbricks.

# Generates a 64-character hex string (32 bytes)
resource "random_id" "nextauth_secret" {
  byte_length = 32
}

resource "random_id" "encryption_key" {
  byte_length = 32
}

resource "random_id" "cron_secret" {
  byte_length = 32
}


resource "aws_ecs_task_definition" "formbricks" {
  family                   = "${var.project}_ECS_TaskDefinition_${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  cpu                      = var.cpu_units
  memory                   = var.memory

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "ghcr.io/formbricks/formbricks:4.7.5"
      cpu       = var.cpu_units
      memory    = var.memory
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name = "REDIS_URL"
          # Construct the URL using the address and port from the endpoint object. Use secure redis connection (rediss) since ElastiCache Serverless mandates in-transit encryption.
          # Note: If insecure redis connection is used, container logs will show a connection is established but application will timeout on login. 
          value = "rediss://${aws_elasticache_serverless_cache.main.endpoint[0].address}:${aws_elasticache_serverless_cache.main.endpoint[0].port}"
        },
        # Formbricks requires S3_ACCESS_KEY and S3_SECRET_KEY as explicit env vars These are visible in the ECS console
        # consider storing them in Secrets Manager and referencing them via the secrets block if stricter security is needed.
        {
          name  = "S3_ACCESS_KEY"
          value = aws_iam_access_key.formbricks_s3_keys.id
        },
        {
          name  = "S3_SECRET_KEY"
          value = aws_iam_access_key.formbricks_s3_keys.secret
        },
        {
          name  = "S3_REGION"
          value = aws_s3_bucket.formbricks_bucket.region
        },
        {
          name  = "S3_BUCKET_NAME"
          value = aws_s3_bucket.formbricks_bucket.id
        },
        # Essential Formbricks ENV Variables
        {
          name  = "NEXTAUTH_SECRET"
          value = random_id.nextauth_secret.hex
        },
        {
          name  = "ENCRYPTION_KEY"
          value = random_id.encryption_key.hex
        },
        {
          name  = "CRON_SECRET"
          value = random_id.cron_secret.hex
        },
        {
          name  = "WEBAPP_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "NEXTAUTH_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "EMAIL_VERIFICATION_DISABLED" # Disable email verification for demo; in production, Enable and configure SMTP. https://formbricks.com/docs/self-hosting/configuration/smtp
          value = "1"
        },
        {
          name  = "PASSWORD_RESET_DISABLED"
          value = "1"
        }
      ]
      # Sensitive Secrets (ValueFrom ARNs)
      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.formbricks_url.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "${var.service_name}-log-stream-${var.environment}"
        }
      }
    }
  ])

  # Provision after DB initializes so that tasks don't repeatedly fail until the DB is ready.
  depends_on = [aws_db_instance.formbricks]

}