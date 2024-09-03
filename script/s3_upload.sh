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
      if [[ ${dir} == "contents" ]]; then src_dir="teamsite"; else src_dir="${dir}"; fi
      aws s3 cp "${src_dir}/${file}" "s3://${BUCKET_NAME}/${dir}/${file}"
    done
    echo "\`\`\`"
  } >> "$GITHUB_STEP_SUMMARY"

  # Delete Files
  {
    echo "### Delete Command Result (\`${dir}\`) 🔥" >> "$GITHUB_STEP_SUMMARY"
    echo "\`\`\`" >> "$GITHUB_STEP_SUMMARY"
    for file in $(git diff "${DIFF_COMMIT}" --name-only --relative="${dir}" --diff-filter=D); do
      aws s3 rm "s3://${BUCKET_NAME}/${dir}/${file}" >> "$GITHUB_STEP_SUMMARY" || true
    done
    echo "\`\`\`"
  } >> "$GITHUB_STEP_SUMMARY"
done
