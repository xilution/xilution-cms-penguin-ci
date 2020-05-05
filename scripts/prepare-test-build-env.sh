#!/bin/bash

set -x

. ./scripts/common_functions.sh

awsAccountId=${1}
role=${2}

export_assume_role_credentials "$awsAccountId" "$role"
update_kubeconfig "$K8S_CLUSTER_NAME"
