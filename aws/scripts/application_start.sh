#!/bin/bash

echo "=============="
echo "ApplicationStart"
echo "=============="

cd /opt/redash_fargate
# export IMAGE_TAG=${BUNDLE_COMMIT}
echo $IMAGE_TAG

printenv
