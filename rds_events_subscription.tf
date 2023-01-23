# --target aws_cloudwatch_event_rule.rds_cluster_event --target aws_cloudwatch_event_rule.rds_instance_event --target aws_cloudwatch_event_target.rds_cluster_event --target aws_cloudwatch_event_target.rds_instance_event --target aws_sns_topic.rds_event_subscription

#########################################
#
# 通知関連
#
#########################################

# resource "aws_sns_topic" "rds_event_subscription" {
#   name = "rds-event-subscription"
# }

# resource "aws_cloudwatch_event_rule" "rds_cluster_event" {
#   name          = "rds_cluster_event"
#   description   = "Find RDS Cluster Event"
#   event_pattern = <<PATTERN
# {
#   "source": ["aws.rds"],
#   "detail-type": ["RDS DB Cluster Event"]
# }
# PATTERN
# }

# resource "aws_cloudwatch_event_rule" "rds_instance_event" {
#   name          = "rds_instance_event"
#   description   = "Find RDS Instance Event"
#   event_pattern = <<PATTERN
# {
#   "source": ["aws.rds"],
#   "detail-type": ["RDS DB Instance Event"]
# }
# PATTERN
# }

# resource "aws_cloudwatch_event_target" "rds_cluster_event" {
#   target_id = "RDSClusterEvent"
#   rule      = aws_cloudwatch_event_rule.rds_cluster_event.name
#   arn       = aws_sns_topic.rds_event_subscription.arn
# }

# resource "aws_cloudwatch_event_target" "rds_instance_event" {
#   target_id = "RDSInstanceEvent"
#   rule      = aws_cloudwatch_event_rule.rds_instance_event.name
#   arn       = aws_sns_topic.rds_event_subscription.arn
# }



#########################################
#
# Aurora
#
#########################################

# resource "aws_rds_cluster" "event_subscription" {
#   apply_immediately   = true
#   cluster_identifier  = "event-subscription-cluster"
#   engine              = "aurora-mysql"
#   engine_version      =  "8.0.mysql_aurora.3.02.2" #"8.0.23.mysql_aurora.3.02.2"
#   db_subnet_group_name = aws_db_subnet_group.postgres.name
#   vpc_security_group_ids                = [aws_security_group.db.id]
#   master_username     = "admin"
#   master_password     = "password"
#   port                = 3306
#   skip_final_snapshot = true
# }

# resource "aws_rds_cluster_instance" "event_subscription" {
#   identifier           = "event-subscription-primary"
#   cluster_identifier   = aws_rds_cluster.event_subscription.id
#   engine               = "aurora-mysql"
#   engine_version       = "8.0.mysql_aurora.3.02.2"
#   instance_class       = "db.t3.medium"
#   db_subnet_group_name = aws_db_subnet_group.postgres.name
#   apply_immediately    = true
# }

# resource "aws_rds_cluster_instance" "event_subscription1" {
#   identifier           = "event-subscription1"
#   cluster_identifier   = aws_rds_cluster.event_subscription.id
#   engine               = "aurora-mysql"
#   engine_version       = "8.0.mysql_aurora.3.02.2"
#   instance_class       = "db.t3.medium"
#   db_subnet_group_name = aws_db_subnet_group.postgres.name
#   apply_immediately    = true
# }

# resource "aws_db_event_subscription" "db_instance" {
#   name      = "rds-db-instance-event"
#   sns_topic = aws_sns_topic.rds_event_subscription.arn

#   source_type = "db-instance"
#   event_categories = [
#     "backup",
#     "deletion",
#     "availability",
#     "creation",
#     "low storage",
#     "restoration",
#     "configuration change",
#     "failover",
#     "maintenance",
#     "failure",
#     "notification",
#     "read replica",
#     "recovery",
#     "security",
#     "backtrack",
#     "security patching"
#   ]
# }

# resource "aws_db_event_subscription" "db_cluster" {
#   name      = "rds-db-cluster-event"
#   sns_topic = aws_sns_topic.rds_event_subscription.arn

#   source_type = "db-cluster"
#   event_categories = [
#     "failover",
#     "migration",
#     "failure",
#     "notification",
#     "serverless",
#     "creation",
#     "deletion",
#     "maintenance",
#     "configuration change",
#     "global-failover"
#   ]
# }
