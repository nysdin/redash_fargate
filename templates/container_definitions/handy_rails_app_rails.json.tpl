[
  {
    "name": "rails",
    "image": "292687378741.dkr.ecr.ap-northeast-1.amazonaws.com/handy-rails-app:latest",
    "cpu": 256,
    "memoryReservation": 512,
    "essential": true,
    "command": ["bundle", "exec", "rails", "server"],
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "logConfiguration": {
      "logDriver": "awsfirelens"
    },
    "environment": [
      {
        "name": "RAILS_ENV",
        "value": "production"
      },
      {
        "name": "RAILS_LOG_TO_STDOUT",
        "value": "true"
      },
      {
        "name": "DB_USER",
        "value": "root"
      },
      {
        "name": "DB_PASSWORD",
        "value": "password"
      }
    ]
  },
  {
    "name": "db",
    "image": "mysql:8.0",
    "cpu": 512,
    "memoryReservation": 1024,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3306,
        "hostPort": 3306
      }
    ],
    "logConfiguration": {
      "logDriver": "awsfirelens"
    },
    "environment": [
      {
        "name": "DB_USER",
        "value": "admin"
      },
      {
        "name": "MYSQL_ROOT_PASSWORD",
        "value": "password"
      },
      {
        "name": "MYSQL_DATABASE",
        "value": "handy_rails_app_production"
      }
    ]
  },
  {
    "name": "log_router",
    "image": "amazon/aws-for-fluent-bit:init-latest",
    "essential": true,
    "firelensConfiguration": {
      "type": "fluentbit",
      "options": { "enable-ecs-log-metadata": "true" }
    },
    "environment": [
      {
        "name": "LOG_GROUP_NAME",
        "value": "/ecs/rails_handy_app"
      },
      {
        "name": "aws_fluent_bit_init_s3_1",
        "value": "arn:aws:s3:::nysdin-aws-for-fluent-bit-config/outputs.conf"
      },
      {
        "name": "aws_fluent_bit_init_s3_2",
        "value": "arn:aws:s3:::nysdin-aws-for-fluent-bit-config/parsers.conf"
      },
      {
        "name": "aws_fluent_bit_init_s3_3",
        "value": "arn:aws:s3:::nysdin-aws-for-fluent-bit-config/filters.conf"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/rails_handy_app",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
