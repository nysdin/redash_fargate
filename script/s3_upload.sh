#!/bin/bash

set -eCo pipefail

: "${BUCKET_NAME:?}"
: "${SYNC_DIRS:?}"
: "${DIFF_COMMIT:?}"
GITHUB_STEP_SUMMARY="${GITHUB_STEP_SUMMARY:-"/dev/stdout"}"

for dir in ${SYNC_DIRS}; do
  # Upload Files
  {
    echo "### Upload Command Result (\`${dir}\`) 🚀" >> "$GITHUB_STEP_SUMMARY"
    echo "\`\`\`" >> "$GITHUB_STEP_SUMMARY"
    for file in $(git diff "${DIFF_COMMIT}" --name-only --relative="${dir}" --diff-filter=d); do
      if [[ ${dir} == "contents" ]]; then s3_dir="teamsite"; else s3_dir="${dir}"; fi
      aws s3 cp "${dir}/${file}" "s3://${BUCKET_NAME}/${s3_dir}/${file}"
    done
    echo "\`\`\`"
  } >> "$GITHUB_STEP_SUMMARY" 2>&1

  # Delete Files
  {
    echo "### Delete Command Result (\`${dir}\`) 🔥" >> "$GITHUB_STEP_SUMMARY"
    echo "\`\`\`" >> "$GITHUB_STEP_SUMMARY"
    for file in $(git diff "${DIFF_COMMIT}" --name-only --relative="${dir}" --diff-filter=D); do
      aws s3 rm "s3://${BUCKET_NAME}/${dir}/${file}" >> "$GITHUB_STEP_SUMMARY" || true
    done
    echo "\`\`\`"
  } >> "$GITHUB_STEP_SUMMARY" 2>&1
done
