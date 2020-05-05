#!/bin/bash

set -x

. ./scripts/common_functions.sh

stageName=${1}
pathToExcludeStages=${2}
pathToTestCommands=${3}

excludeStages=$(yq read ./xilution.yaml -j | jq -r "$pathToExcludeStages | @base64")
testCommands=$(yq read ./xilution.yaml -j | jq -r "$pathToTestCommands | @base64")

export_skip_tests "$excludeStages" "$stageName"
if [[ $SKIP_TESTS -eq 0 ]]
then
  export_load_balancer_hostname
  export_wordpress_site_url "$LOAD_BALANCER_HOSTNAME" "$PENGUIN_PIPELINE_ID" "$stageName"
  wait_for_site_to_be_ready "$WORDPRESS_SITE_URL"
  execute_commands "$testCommands"
fi
