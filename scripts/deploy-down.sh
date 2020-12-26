#!/bin/bash -e

pipelineId=${PENGUIN_PIPELINE_ID}
stageName=${STAGE_NAME}
stageNameLower=$(echo "${stageName}" | tr '[:upper:]' '[:lower:]')

helm tiller run tiller -- helm delete wordpress-"${pipelineId:0:8}"-"${stageNameLower}"
helm tiller run tiller -- helm del --purge wordpress-"${pipelineId:0:8}"-"${stageNameLower}"
