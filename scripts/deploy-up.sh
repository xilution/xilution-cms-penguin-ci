#!/bin/bash -ex

buildDir=${CODEBUILD_SRC_DIR_BuildDeployImage}
pipelineId=${PENGUIN_PIPELINE_ID}
stageName=${STAGE_NAME}
loadBalancerHostname=$(kubectl get services/ingress-nginx -n ingress-nginx -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

echo "the contents of the build dir is:"
ls "${buildDir}"

helm tiller run tiller -- helm upgrade \
  --install \
  --force \
  --namespace wordpress \
  --set mysql.name=wordpress-"$pipelineId"-"$stageName" \
  --set host="$loadBalancerHostname" \
  --set path=/wordpress/"$pipelineId"/"$stageName" \
  --values "$buildDir"/image.yaml \
  wordpress-"$pipelineId"-"$stageName" ./helm/wordpress
