#!/bin/bash

set -eCo pipefail

: "${BUCKET_NAME:?}"
: "${SYNC_DIRS:?}"
: "${DRYRUN:-false?}"
GITHUB_STEP_SUMMARY="${GITHUB_STEP_SUMMARY:-"/dev/stdout"}"
S3_OPTIONS="--delete --size-only"
if [[ ${DRYRUN} == "true" ]]; then S3_OPTIONS="${S3_OPTIONS} --dryrun"; fi

for dir in ${SYNC_DIRS}; do
  {
    echo "### Sync Command Result (\`${dir}\`) 🚀" >> "$GITHUB_STEP_SUMMARY"
    echo "\`\`\`" >> "$GITHUB_STEP_SUMMARY"
    if [[ ${dir} == "contents" ]]; then s3_dir="teamsite"; else s3_dir="${dir}"; fi
    aws s3 sync "${dir}" "s3://${BUCKET_NAME}/${s3_dir}" ${S3_OPTIONS}
    echo "\`\`\`"
  } >> "$GITHUB_STEP_SUMMARY" 2>&1
done
