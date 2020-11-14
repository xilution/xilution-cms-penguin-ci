#!/bin/bash -ex

pipelineId=${PENGUIN_PIPELINE_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')

jq_query=".status.loadBalancer.ingress[0].hostname"
lb_host_name=$(kubectl get services/ingress-nginx -n ingress-nginx -o json | jq -r "${jq_query}")
site_base_url="http://${lb_host_name}/wordpress/${pipelineId:0:8}/${stageNameLower}"

export SITE_BASE_URL=${site_base_url}
