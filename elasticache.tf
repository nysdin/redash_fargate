resource "aws_elasticache_replication_group" "redash" {
  replication_group_id        = "redash-redis"
  description                 = "redis for redash"
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  automatic_failover_enabled  = false
  engine                      = "redis"
  engine_version              = "7.0"
  maintenance_window          = "sun:20:00-sun:21:00"
  multi_az_enabled            = false
  node_type                   = "cache.t3.micro"
  num_cache_clusters          = 1
  parameter_group_name        = "default.redis7"
  port                        = "6379"
  preferred_cache_cluster_azs = ["ap-northeast-1a"]
  security_group_ids          = [aws_security_group.redis.id]
  subnet_group_name           = aws_elasticache_subnet_group.redash.name
}

resource "aws_elasticache_subnet_group" "redash" {
  name       = "redash-subnet"
  subnet_ids = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
}
