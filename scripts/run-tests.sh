#!/bin/bash -ex

set -x

. ./scripts/common_functions.sh

penguinPipelineId=${1}
stageName=${2}
sourceDir=${3}

export_load_balancer_hostname
export_wordpress_site_url "$LOAD_BALANCER_HOSTNAME" "$penguinPipelineId" "$stageName"
wait_for_site_to_be_ready "$WORDPRESS_SITE_URL"

cd "$sourceDir" || false

testDetails=$(yq read ./xilution.yaml -j | jq -r ".tests[]? | @base64")

for testDetail in $testDetails; do
  commands=$(echo "$testDetail" | jq -r ".commands? | @base64")
  excludeStages=$(echo "$testDetail" | jq -r ".excludeStages? | @base64")

  export_skip_tests "$excludeStages" "$stageName"
  if [[ $SKIP_TESTS -eq 0 ]]
  then
    execute_commands "$commands"
  fi
done
