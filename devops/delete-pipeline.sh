#!/usr/bin/env bash

set -e

currentDirectory=${PWD##*/}
echo "Using current directory: $currentDirectory to set stack name"

stackName="$currentDirectory-pipeline"

echo "Deleting pipeline stack $stackName"
aws cloudformation delete-stack \
  --stack-name "$stackName" \
  --profile xilution-shared
