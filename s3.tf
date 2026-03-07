# 1. The S3 Bucket
resource "aws_s3_bucket" "formbricks_bucket" {
  bucket_prefix = var.bucket_name
  force_destroy = true
}

# 2. Mandatory CORS Configuration for formbricks
resource "aws_s3_bucket_cors_configuration" "formbricks_bucket_cors" {
  bucket = aws_s3_bucket.formbricks_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["https://${var.domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_public_access_block" "formbricks_bucket_privacy" {
  bucket = aws_s3_bucket.formbricks_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. IAM User for formbricks
resource "aws_iam_user" "formbricks_s3" {
  name = "s3-ecs-formbricks-user"
}

# Generate Access Keys for the formbricks
resource "aws_iam_access_key" "formbricks_s3_keys" {
  user = aws_iam_user.formbricks_s3.name
}

resource "aws_iam_user_policy" "formbricks_s3_policy" {
  name = "AppSpecificS3Access"
  user = aws_iam_user.formbricks_s3.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.formbricks_bucket.arn,
          "${aws_s3_bucket.formbricks_bucket.arn}/*"
        ]
      }
    ]
  })
}