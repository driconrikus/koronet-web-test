# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.app_name}-cache-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.app_name}-cache-subnet-group"
  }
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "main" {
  family = "redis7.x"
  name   = "${var.app_name}-cache-params"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = {
    Name = "${var.app_name}-cache-parameter-group"
  }
}

# ElastiCache Replication Group (Redis)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id         = "${var.app_name}-redis"
  description                  = "Redis cluster for Koronet application"

  # Redis configuration
  node_type                    = var.redis_node_type
  port                         = 6379
  parameter_group_name         = aws_elasticache_parameter_group.main.name

  # Cluster configuration
  num_cache_clusters           = 2
  automatic_failover_enabled   = true
  multi_az_enabled             = true
  at_rest_encryption_enabled   = true
  transit_encryption_enabled   = true
  auth_token                   = random_password.redis_auth_token.result

  # Network configuration
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  # Maintenance
  maintenance_window         = "sun:05:00-sun:06:00"
  snapshot_retention_limit   = 5
  snapshot_window           = "03:00-05:00"

  # Logging
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  tags = {
    Name = "${var.app_name}-redis"
  }
}

# Random auth token for Redis
resource "random_password" "redis_auth_token" {
  length  = 32
  special = true
}

# CloudWatch Log Group for Redis slow log
resource "aws_cloudwatch_log_group" "redis_slow_log" {
  name              = "/aws/elasticache/redis/slow-log"
  retention_in_days = 7

  tags = {
    Name = "${var.app_name}-redis-slow-log"
  }
}
