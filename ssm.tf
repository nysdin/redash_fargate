locals {
  db_password         = data.sops_file.secrets.data["db_password"]
  postgresql_endpoint = aws_db_instance.postgres.address
  redis_endpoint      = aws_elasticache_replication_group.redash.primary_endpoint_address

  redash_database_url = "postgresql://nysdin:${local.db_password}@${local.postgresql_endpoint}/redash"
  redash_redis_url    = "redis://${local.redis_endpoint}:6379/0"
}

#########################################
#
# Parameter Store
#
#########################################

resource "aws_ssm_parameter" "redash_postgresql_url" {
  name        = "/redash/database/postgresql/url"
  description = "DATABASE URL for redash PostgreSQL"
  type        = "SecureString"
  value       = local.redash_database_url
}

resource "aws_ssm_parameter" "redash_redis_url" {
  name        = "/redash/redis/url"
  description = "Redis URL for redash"
  type        = "SecureString"
  value       = local.redash_redis_url
}

resource "aws_ssm_parameter" "mackerel_apikey" {
  name        = "/mackerel/apikey"
  description = "Default Mackerel APIKEY"
  type        = "SecureString"
  value       = data.sops_file.secrets.data["mackerel_apikey"]
}
