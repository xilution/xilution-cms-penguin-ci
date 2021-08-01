#!/bin/bash -e

currentDir=$(pwd)
cd ./terraform/trunk

terraform apply -no-color \
  -var="organization_id=$XILUTION_ORGANIZATION_ID" \
  -var="penguin_pipeline_id=$PENGUIN_PIPELINE_ID" \
  -var="giraffe_pipeline_id=$GIRAFFE_PIPELINE_ID" \
  -var="k8s_cluster_name=$K8S_CLUSTER_NAME" \
  -var="master_username=$MASTER_USERNAME" \
  -var="master_password=$MASTER_PASSWORD" \
  -var="docker_username=$DOCKER_USERNAME" \
  -var="docker_password=$DOCKER_PASSWORD" \
  -var="client_aws_account=$CLIENT_AWS_ACCOUNT" \
  -var="client_aws_region=$CLIENT_AWS_REGION" \
  -var="xilution_aws_account=$XILUTION_AWS_ACCOUNT" \
  -var="xilution_aws_region=$XILUTION_AWS_REGION" \
  -var="xilution_environment=$XILUTION_ENVIRONMENT" \
  -var="xilution_pipeline_type=$PIPELINE_TYPE" \
  -auto-approve \
  ./terraform-plan.txt

cd ${currentDir}
