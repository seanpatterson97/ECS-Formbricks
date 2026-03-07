resource "aws_elasticache_serverless_cache" "main" {
  engine = "valkey"
  name   = "formbricks-valkey-cache"
  cache_usage_limits {
    data_storage {
      maximum = 10
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 1000 # minimum ecpu allowable for demonstration purposes
    }
  }
  description          = "Formbricks Cluster Valkey Cache"
  major_engine_version = "8"
  security_group_ids   = [aws_security_group.elasticache.id]
  subnet_ids           = aws_subnet.private[*].id
}