#!/bin/bash

echo "=============="
echo "ApplicationStart"
echo "=============="

cd /opt/redash_fargate
# export IMAGE_TAG=${BUNDLE_COMMIT}
echo $IMAGE_TAG

printenv
echo "start sleep 180"
sleep 180
echo "finish sleep 180"
docker-compose up -d
