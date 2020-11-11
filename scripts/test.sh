#!/bin/bash -ex

. ./scripts/common_functions.sh

pipelineId=${PENGUIN_PIPELINE_ID}
stageName=${STAGE_NAME}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}

loadBalancerHostName=$(kubectl get services/ingress-nginx -n ingress-nginx -o json | jq -r ".status.loadBalancer.ingress[0].hostname")
siteUrl="http://${loadBalancerHostName}/wordpress/${pipelineId}/${stageName}"

wait_for_site_to_be_ready "${siteUrl}"

currentDir=$(pwd)
cd "${sourceDir}" || false

testDetails=$(jq -r ".tests.${stageName}[] | @base64" <./xilution.json)

for testDetail in ${testDetails}; do
  testName=$(echo "${testDetail}" | base64 --decode | jq -r ".name?")
  echo "Running: ${testName}"
  commands=$(echo "${testDetail}" | base64 --decode | jq -r ".commands[]? | @base64")
  execute_commands "${commands}"
done

cd "${currentDir}" || false
