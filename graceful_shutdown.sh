#!/bin/bash

AUTO_SCALING_GROUP_NAME=${1:-"yanada-test"}
LIFECYCLE_HOOK_NAME=${2:-"graceful-termination"}
INTERVAL=30
TIMEOUT=${GRACEFUL_SHUTDOWN_TIMEOUT:-3600}
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/instance-id)
export AWS_DEFAULT_REGION=ap-northeast-1

# Function to check if there are in-progress RunCommand invocations
function exists_in_progress_run_command() {
  local instance_id=$1

  if [[ $(aws ssm list-command-invocations --instance-id "${instance_id}" --filters key=Status,value=InProgress | jq -r '.CommandInvocations | length') -gt 0 ]]; then
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
for ((i = 0; i < TIMEOUT / INTERVAL; i++)); do
  if exists_in_progress_run_command "${INSTANCE_ID}"; then
    echo "waiting for existing RunCommand to complete..."
    sleep $INTERVAL
  else
    break
  fi
done

# Display the list of RunCommand with InProgress Status (may be killed by timeout)
if exists_in_progress_run_command "${INSTANCE_ID}"; then
  echo "RunCommand on instance(${INSTANCE_ID}) is still running. But Timeout..."
  echo "Below is the list of RunCommand with InProgress Status"
  aws ssm list-command-invocations --instance-id "${INSTANCE_ID}" --filters key=Status,value=InProgress | jq -r '.CommandInvocations[] | "CommandID: \(.CommandId), Status: \(.Status)"'
else
  echo "All RunCommand on instance($INSTANCE_ID) is completed!!!"
fi

# Complete the lifecycle action
aws autoscaling complete-lifecycle-action --lifecycle-hook-name "${LIFECYCLE_HOOK_NAME}" --auto-scaling-group-name "${AUTO_SCALING_GROUP_NAME}" --instance-id "${INSTANCE_ID}" --lifecycle-action-result CONTINUE
