#!/bin/bash

echo "=============="
echo "ApplicationStop"
echo "=============="

cd /opt/redash_fargate
ls
docker-compose down
