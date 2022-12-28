[
  {
    "name": "redash-create-db",
    "image": "redash/redash:10.0.0.b50363",
    "cpu": 1024,
    "memory": 2048,
    "memoryReservation": 1024,
    "essential": true,
    "command": [
      "create_db"
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${awslogs_group}",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "secrets": [
      {
        "name": "REDASH_DATABASE_URL",
        "valueFrom": "${redash_database_url_ssm_arn}"
      },
      {
        "name": "REDASH_REDIS_URL",
        "valueFrom": "${redash_redis_url_ssm_arn}"
      }
    ],
    "environment": [
      {
        "name": "PYTHONUNBUFFERED",
        "value": "1"
      },
      {
        "name": "REDASH_ALLOW_SCRIPTS_IN_USER_INPUT",
        "value": "true"
      },
      {
        "name": "REDASH_LOG_LEVEL",
        "value": "INFO"
      },
      {
        "name": "REDASH_LOG_STDOUT",
        "value": "true"
      },
      {
        "name": "REDASH_DATE_FORMAT",
        "value": "YY/DD/MM"
      },
      {
        "name": "REDASH_PASSWORD_LOGIN_ENABLED",
        "value": "true"
      }
    ]
  }
]
