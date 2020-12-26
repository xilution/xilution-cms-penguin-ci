#!/bin/bash -e

terraform destroy \
  -var="organization_id=$XILUTION_ORGANIZATION_ID" \
  -var="penguin_pipeline_id=$PENGUIN_PIPELINE_ID" \
  -var="giraffe_pipeline_id=$GIRAFFE_PIPELINE_ID" \
  -var="k8s_cluster_name=nonsense" \
  -var="master_username=nonsense" \
  -var="master_password=nonsense" \
  -var="docker_username=nonsense" \
  -var="docker_password=nonsense" \
  -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
  -var="client_aws_region=$CLIENT_AWS_REGION" \
  -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
  -var="xilution_aws_region=$XILUTION_AWS_REGION" \
  -var="xilution_environment=$XILUTION_ENVIRONMENT" \
  -var="xilution_pipeline_type=$PIPELINE_TYPE" \
  -auto-approve \
  ./terraform/trunk
