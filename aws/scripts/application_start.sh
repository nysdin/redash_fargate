#!/bin/bash

echo "=============="
echo "ApplicationStart"
echo "=============="

cd /opt/redash_fargate
# export IMAGE_TAG=${BUNDLE_COMMIT}
echo $IMAGE_TAG
if [[ "$DEPLOYMENT_GROUP_NAME" == "Staging" ]]
then
  export ENV=stgpo
    sed -i -e 's/Listen 80/Listen 9090/g' /etc/httpd/conf/httpd.conf
fi
