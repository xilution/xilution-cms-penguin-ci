#!/bin/bash -ex

buildDir=${CODEBUILD_SRC_DIR_BuildDeployImage}
pipelineId=${PENGUIN_PIPELINE_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')
loadBalancerHostname=$(kubectl get services/ingress-nginx -n ingress-nginx -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

helm tiller run tiller -- helm upgrade \
  --install \
  --force \
  --namespace wordpress \
  --set mysql.name=wordpress-"${pipelineId:0:8}"-"${stageNameLower}" \
  --set host="$loadBalancerHostname" \
  --set path=/wordpress/"${pipelineId:0:8}"/"${stageNameLower}" \
  --values "${buildDir}"/image.yaml \
  wordpress-"${pipelineId:0:8}"-"${stageNameLower}" ./helm/wordpress
