#!/bin/bash

echo "=============="
echo "ApplicationStop"
echo "=============="

cd /opt/redash_fargate
docker-compose down
