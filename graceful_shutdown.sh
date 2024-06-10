#!/bin/bash -x

AUTO_SCALING_GROUP_NAME=${1:-"yanada-test"}
LIFECYCLE_HOOK_NAME=${2:-"graceful-termination"}
INTERVAL=${INTERVAL:-30}

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/instance-id)
export AWS_DEFAULT_REGION=ap-northeast-1

# Function to check if there are in-progress RunCommand invocations
function exists_in_progress_run_command() {
  local instance_id=$1

  # This script is executed by RunCommand, so there is always one RunCommand in progress.
  if [[ $(aws ssm list-command-invocations --instance-id "${instance_id}" --filters key=Status,value=InProgress | jq -r '.CommandInvocations | length') -gt 1 ]]; then
    aws ssm list-command-invocations --instance-id "i-08961468a7b2764f9" --filters key=Status,value=InProgress | jq -r '.CommandInvocations[] | "CommandID: \(.CommandId), Status: \(.Status)"'
    return 0
  else
    return 1
  fi
}

echo "Stopping acceptance of new job requests..."
aws ec2 create-tags --resources "${INSTANCE_ID}" --tags Key=State,Value=Terminating

# Wait for the attached tag to be reflected
while ! aws ssm describe-instance-information --filters Key=tag:ServiceType,Values=Batch Key=tag:State,Values=Terminating --query "InstanceInformationList[].[InstanceId]" --output text | grep "${INSTANCE_ID}"
do
  echo "Waiting for the attached tag to be reflected..."
  sleep 30
done
echo "Stopped accepting new job requests."

# Wait for the instance to complete InProgress RunCommands
while exists_in_progress_run_command "${INSTANCE_ID}"
do
  echo "waiting for existing RunCommand to complete..."
  aws ssm list-command-invocations --instance-id "${INSTANCE_ID}" --filters key=Status,value=InProgress | jq -r '.CommandInvocations[] | "CommandID: \(.CommandId), Status: \(.Status)"'
  sleep "${INTERVAL}"
done

# Complete the lifecycle action
aws autoscaling complete-lifecycle-action --lifecycle-hook-name "${LIFECYCLE_HOOK_NAME}" --auto-scaling-group-name "${AUTO_SCALING_GROUP_NAME}" --instance-id "${INSTANCE_ID}" --lifecycle-action-result CONTINUE
