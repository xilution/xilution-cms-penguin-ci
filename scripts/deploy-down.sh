#!/bin/bash -ex

pipelineId=${PENGUIN_PIPELINE_ID}
stageName=${STAGE_NAME}

helm tiller run tiller -- helm delete wordpress-"$pipelineId"-"$stageName"
helm tiller run tiller -- helm del --purge wordpress-"$pipelineId"-"$stageName"
