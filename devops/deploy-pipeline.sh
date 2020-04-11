#!/usr/bin/env bash

set -e

currentDirectory=${PWD##*/}
echo "Using current directory: $currentDirectory to set stack name"

stackName="$currentDirectory-pipeline"

echo "Verifying resources template"
aws cloudformation validate-template \
  --template-body file://./aws/cloudformation/resources.yml \
  --profile xilution-shared

echo "Verifying pipeline cloudformation template for $stackName"
aws cloudformation validate-template \
  --template-body file://./devops/pipeline.yml \
  --profile xilution-shared

echo "Deploying pipeline stack $stackName"
aws cloudformation deploy --stack-name "$stackName" \
  --template-file devops/pipeline.yml \
  --parameter-overrides Repository="$currentDirectory" \
      XilutionSharedAccountId="$AWS_SHARED_ACCOUNT_ID" \
      XilutionProdAccountId="$AWS_PROD_ACCOUNT_ID" \
  --profile xilution-shared \
  --no-fail-on-empty-changeset
