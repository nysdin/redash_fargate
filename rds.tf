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
