#########################################
#
# redash postgresql
#
#########################################

resource "aws_db_instance" "postgres" {
  allocated_storage                     = "20"
  allow_major_version_upgrade           = false
  auto_minor_version_upgrade            = true // ダウンタイム発生する？
  availability_zone                     = "ap-northeast-1a"
  backup_window                         = "18:00-18:30"
  copy_tags_to_snapshot                 = false
  db_name                               = "redash"
  db_subnet_group_name                  = aws_db_subnet_group.postgres.id
  delete_automated_backups              = true
  deletion_protection                   = true
  enabled_cloudwatch_logs_exports       = ["postgresql"]
  engine                                = "postgres"
  engine_version                        = "14.5"
  iam_database_authentication_enabled   = true
  identifier                            = "redash"
  instance_class                        = "db.t4g.micro"
  maintenance_window                    = "Mon:16:00-Mon:16:30"
  max_allocated_storage                 = 0
  monitoring_interval                   = 0
  multi_az                              = false
  password                              = data.sops_file.secrets.data["redash_postgresql_db_password"]
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = data.aws_kms_key.main.arn
  performance_insights_retention_period = 7
  port                                  = 5432
  publicly_accessible                   = true
  skip_final_snapshot                   = true
  storage_type                          = "gp2"
  username                              = "nysdin"
  vpc_security_group_ids                = [aws_security_group.db.id]
  tags = {
    "Mackerel" = "true"
  }
}

resource "aws_db_subnet_group" "postgres" {
  name = "redash-postgresql-subnet-group"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id,
  ]
}

#########################################
#
# redash DataSource
#
#########################################

# データソース用のDB作らなくても、redashのメタデータを格納するpostgresqlを
# データソースとして活用できるので消しちゃう

# resource "aws_db_instance" "redash_datasource" {
#   allocated_storage                     = "20"
#   allow_major_version_upgrade           = false
#   auto_minor_version_upgrade            = true // ダウンタイム発生する？
#   availability_zone                     = "ap-northeast-1c"
#   backup_window                         = "18:00-18:30"
#   copy_tags_to_snapshot                 = false
#   db_subnet_group_name                  = aws_db_subnet_group.redash_datasource.id
#   delete_automated_backups              = true
#   deletion_protection                   = true
#   enabled_cloudwatch_logs_exports       = ["audit", "error", "slowquery"]
#   engine                                = "mysql"
#   engine_version                        = "8.0.31"
#   iam_database_authentication_enabled   = true
#   identifier                            = "redash-datasource"
#   instance_class                        = "db.t4g.micro"
#   maintenance_window                    = "Mon:16:00-Mon:16:30"
#   max_allocated_storage                 = 0
#   monitoring_interval                   = 0
#   multi_az                              = false
#   password                              = data.sops_file.secrets.data["redash_datasource_db_password"]
#   performance_insights_enabled          = true
#   performance_insights_kms_key_id       = aws_kms_key.main.arn
#   performance_insights_retention_period = 7
#   port                                  = 3306
#   publicly_accessible                   = false
#   skip_final_snapshot                   = true
#   storage_type                          = "gp2"
#   username                              = "nysding" #typoしてる・・ 注意・・
#   vpc_security_group_ids                = [aws_security_group.db.id]
#   tags = {
#     "Mackerel" = "true"
#   }
# }

resource "aws_db_subnet_group" "redash_datasource" {
  name = "redash_datasource"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id,
  ]
}

# resource "aws_rds_cluster" "bg_test" {
#   cluster_identifier              = "test"
#   engine                          = "aurora-mysql"
#   engine_version                  = "8.0.mysql_aurora.3.02.0"
#   backup_retention_period         = 1
#   master_username                 = "root"
#   master_password                 = "password"
#   skip_final_snapshot             = true
#   preferred_maintenance_window    = "Wed:05:00-Wed:05:30"
#   preferred_backup_window         = "02:00-02:30"
#   vpc_security_group_ids          = ["sg-0dc3ba2874ea7fbc6"]
#   db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.test.name
#   db_subnet_group_name            = "redash_datasource"
#   port                            = 3306
# }


# resource "aws_rds_cluster_instance" "bg_test" {
#   count = 2
#   cluster_identifier      = aws_rds_cluster.bg_test.id
#   db_subnet_group_name    = "redash_datasource"
#   db_parameter_group_name = aws_db_parameter_group.test.name
#   identifier              = "bg-test-${count.index}"
#   instance_class          = "db.t3.medium"
#   preferred_maintenance_window = "Wed:16:00-Wed:16:30"
#   monitoring_interval          = 0
#   engine                          = "aurora-mysql"
#   engine_version                  = "8.0.mysql_aurora.3.02.0"
#   performance_insights_enabled = false
#   publicly_accessible          = false
# }

# resource "aws_rds_cluster" "test1" {
#   cluster_identifier              = "test12344"
#   engine                          = "aurora-mysql"
#   engine_version                  = "8.0.mysql_aurora.3.01.0"
#   backup_retention_period         = 1
#   master_username                 = "root"
#   master_password                 = "password"
#   skip_final_snapshot             = true
#   preferred_maintenance_window    = "Wed:05:00-Wed:05:30"
#   preferred_backup_window         = "02:00-02:30"
#   vpc_security_group_ids          = ["sg-0dc3ba2874ea7fbc6"]
#   db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.test.name
#   db_subnet_group_name            = "redash_datasource"
#   port                            = 3306
# }


# resource "aws_rds_cluster_instance" "test" {
#   count = 2
#   cluster_identifier      = aws_rds_cluster.test1.id
#   db_subnet_group_name    = "redash_datasource"
#   db_parameter_group_name = aws_db_parameter_group.test.name
#   identifier              = "test-${count.index}"
#   instance_class          = "db.t3.medium"
#   preferred_maintenance_window = "Wed:16:00-Wed:16:30"
#   monitoring_interval          = 0
#   engine                          = "aurora-mysql"
#   engine_version                  = "8.0.mysql_aurora.3.01.0"
#   performance_insights_enabled = false
#   publicly_accessible          = false
# }

#######################################
#
# Parameter Group
#
#######################################


resource "aws_rds_cluster_parameter_group" "bg_test" {
  name   = "bg-test-mysql57-cluster-parameter-group"
  family = "aurora-mysql5.7"
  parameter {
    name  = "sql_mode"
    value = "NO_ENGINE_SUBSTITUTION"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "binlog_format"
    value        = "ROW"
  }
}

resource "aws_db_parameter_group" "bg_test" {
  name   = "bg-test-mysql57-db-parameter-group"
  family = "aurora-mysql5.7"
  parameter {
    name  = "sql_mode"
    value = "NO_ENGINE_SUBSTITUTION"
  }
}

resource "aws_rds_cluster_parameter_group" "test" {
  name   = "bg-test-mysql80-cluster-parameter-group"
  family = "aurora-mysql8.0"
  parameter {
    name  = "sql_mode"
    value = "NO_ENGINE_SUBSTITUTION"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "binlog_format"
    value        = "ROW"
  }
}

resource "aws_db_parameter_group" "test" {
  name   = "bg-test-mysql80-db-parameter-group"
  family = "aurora-mysql8.0"
  parameter {
    name  = "sql_mode"
    value = "NO_ENGINE_SUBSTITUTION"
  }
}
