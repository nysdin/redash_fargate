#########################################
#
# VPC
#
#########################################

resource "aws_vpc" "main" {
  cidr_block           = "10.2.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "redash-vpc"
  }
}


#########################################
#
# Subnet
#
#########################################

resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    "Name" = "redash-public-subnet-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.2.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    "Name" = "redash-public-subnet-1c"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.3.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    "Name" = "redash-private-subnet-1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.4.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    "Name" = "redash-private-subnet-1a"
  }
}

#########################################
#
# Internet Gateway
#
#########################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "redash-igw"
  }
}

#########################################
#
# Route Table
#
#########################################

resource "aws_route_table" "public_1" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "redash-public"
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public_1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_1.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public_1.id
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "redash-private"
  }
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_1.id
}

#########################################
#
# Security Group
#
#########################################

# redash
resource "aws_security_group" "redash" {
  name        = "redash"
  description = "for redash (ecs on fargate)"
  vpc_id      = aws_vpc.main.id

  tags = {
    "Name" = "redash"
  }
}

resource "aws_security_group_rule" "ingress_redash_from_db" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.redash.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "egress_redash_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.redash.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# db
resource "aws_security_group" "db" {
  name        = "db"
  description = "for DB"
  vpc_id      = aws_vpc.main.id

  tags = {
    "Name" = "redash-db"
  }
}

resource "aws_security_group_rule" "ingress_db_from_redash" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.redash.id
}

resource "aws_security_group_rule" "ingress_mysql_from_redash" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.redash.id
}

resource "aws_security_group_rule" "egress_db_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.db.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# redis
resource "aws_security_group" "redis" {
  name        = "redis"
  description = "for redis"
  vpc_id      = aws_vpc.main.id

  tags = {
    "Name" = "redash-redis"
  }
}

resource "aws_security_group_rule" "ingress_redis_from_redash" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = aws_security_group.redash.id
}

resource "aws_security_group_rule" "egress_redis_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.redis.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# alb
resource "aws_security_group" "alb" {
  name        = "redash-alb"
  description = "for ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    "Name" = "redash-alb"
  }
}

resource "aws_security_group_rule" "ingress_alb_from_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_alb_from_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "egress_alb_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}
