# Fetch the raw secret ARN from RDS
data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = aws_db_instance.formbricks.master_user_secret[0].secret_arn
}

# Construct the connection string locally
locals {
  # Parse the JSON from AWS
  db_creds    = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string)
  db_username = urlencode(aws_db_instance.formbricks.username)
  db_password = urlencode(local.db_creds["password"])


  # Build the URL: postgresql://user:pass@host:port/db?schema=public
  formbricks_db_url = "postgresql://${local.db_username}:${local.db_password}@${aws_db_instance.formbricks.address}:${aws_db_instance.formbricks.port}/${aws_db_instance.formbricks.db_name}?schema=public"
}

# Create the "Bridge Secret" for the App
resource "aws_secretsmanager_secret" "formbricks_url" {
  name        = "formbricks/DATABASE_URL"
  description = "Formatted connection string for Formbricks (Production Demo)"

  # CRITICAL FOR DEMOS: Forces immediate deletion when you destroy. Comment or modify the recovery window if using for prod
  # Without this, AWS keeps the secret for 7-30 days and charges for it.
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "formbricks_url_val" {
  secret_id     = aws_secretsmanager_secret.formbricks_url.id
  secret_string = local.formbricks_db_url
}