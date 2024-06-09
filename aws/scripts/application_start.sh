#!/bin/bash

echo "=============="
echo "ApplicationStart"
echo "=============="

aws s3 sync s3://test-hori-bpa /opt/redash_fargate

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 --region ap-northeast-1 create-tags --resources "${INSTANCE_ID}" --tags Key=Running,Value=true

# cd /opt/redash_fargate
# # export IMAGE_TAG=${BUNDLE_COMMIT}
# echo $IMAGE_TAG

# printenv
# echo "start sleep 180"
# sleep 180
# echo "finish sleep 180"
# docker-compose up -d
