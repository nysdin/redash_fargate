#!/bin/bash

date

INSTANCE_ID=i-02cde0c6c74fb02c0

# create tag
aws --profile port-inc-dev:admin --region ap-northeast-1 ec2 create-tags --resources "i-02cde0c6c74fb02c0" --tags Key=Test,Value=Test

# check managed instance
aws --profile port-inc-dev:admin ssm describe-instance-information --filters Key=tag:ServiceType,Values=Batch Key=tag:Test,Values=Test --query "InstanceInformationList[].[InstanceId]" --output text

# check ec2 descreibe-instances
aws --profile port-inc-dev:admin ec2 describe-instances --filters Name=tag:ServiceType,Values=Batch Name=tag:Test,Values=Test --query "Reservations[].Instances[].[InstanceId]" --output text

# wait for the attached tag to be reflected (on managed instance)
while ! aws --profile port-inc-dev:admin ssm describe-instance-information --filters Key=tag:ServiceType,Values=Batch Key=tag:Test,Values=Test --query "InstanceInformationList[].[InstanceId]" --output text | grep "${INSTANCE_ID}"
do
  echo "Waiting for the attached tag to be reflected..."
  sleep 5
done
