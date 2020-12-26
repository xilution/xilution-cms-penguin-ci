#!/bin/bash -e

awsAccountId=${CLIENT_AWS_ACCOUNT}
pipelineId=${PENGUIN_PIPELINE_ID}

terraform init \
  -backend-config="key=xilution-cms-penguin/${pipelineId}/terraform.tfstate" \
  -backend-config="bucket=xilution-terraform-backend-state-bucket-${awsAccountId}" \
  -backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
  ./terraform/trunk
