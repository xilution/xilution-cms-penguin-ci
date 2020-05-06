#!/bin/bash

set -x

. ./scripts/common_functions.sh

awsAccountId=${1}
role=${2}
k8sClusterName=${3}
penguinPipelineId=${4}
srcDir=${5}

export_assume_role_credentials "$awsAccountId" "$role"
update_kubeconfig "$k8sClusterName"
init_terraform "$penguinPipelineId" "$awsAccountId" "$srcDir"
