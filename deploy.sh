#!/bin/bash
set -euCo pipefail

COMMIT_ID=$(git rev-parse HEAD)
echo "${COMMIT_ID}"
aws deploy create-deployment --application-name sample --deployment-group-name sample --github-location repository=nysdin/redash_fargate,commitId=${COMMIT_ID} --file-exists-behavior OVERWRITE --ignore-application-stop-failures
