#!/bin/bash

# reference: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/autoscaling.md

AWS_REGION=$1
CLUSTER_NAME=$2

HELM_HOST=:44134 helm install stable/cluster-autoscaler \
  --set rbac.create=true \
  --set cloudProvider="aws" \
  --set awsRegion="${AWS_REGION}" \
  --set autoDiscovery.clusterName="${CLUSTER_NAME}" \
  --set autoDiscovery.enabled=true
