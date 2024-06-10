#!/bin/bash

echo "=============="
echo "ApplicationStart"
echo "=============="

aws s3 sync s3://test-hori-bpa /opt/assets

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/instance-id)

# s3 sync といったデータロード等の初期化処理が終わった後に、RunCommand の対象となるタグを付与する
aws ec2 --region ap-northeast-1 create-tags --resources "${INSTANCE_ID}" --tags Key=State,Value=Running

# wait for the attached tag to be reflected (on managed instance)
while ! aws ssm describe-instance-information --filters Key=tag:ServiceType,Values=Batch Key=tag:State,Values=Running --query "InstanceInformationList[].[InstanceId]" --output text | grep "${INSTANCE_ID}"
do
  echo "Waiting for the attached tag to be reflected..."
  sleep 15
done

# cd /opt/redash_fargate
# # export IMAGE_TAG=${BUNDLE_COMMIT}
# echo $IMAGE_TAG

# printenv
# echo "start sleep 180"
# sleep 180
# echo "finish sleep 180"
# docker-compose up -d
