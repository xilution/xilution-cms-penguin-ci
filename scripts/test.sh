#!/bin/bash -e

. ./scripts/common_functions.sh

stageName=${STAGE_NAME}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
siteBaseUrl=${SITE_BASE_URL}

wait_for_site_to_be_ready "${siteBaseUrl}"

cd "${sourceDir}" || false

testDetails=$(jq -r ".tests.${stageName}[] | @base64" <./xilution.json)

for testDetail in ${testDetails}; do
  testName=$(echo "${testDetail}" | base64 --decode | jq -r ".name?")
  echo "Running: ${testName}"
  commands=$(echo "${testDetail}" | base64 --decode | jq -r ".commands[]? | @base64")
  execute_commands "${commands}"
done
