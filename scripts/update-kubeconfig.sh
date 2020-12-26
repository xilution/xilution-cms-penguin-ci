#!/bin/bash -e

k8sClusterName=${K8S_CLUSTER_NAME}

aws eks update-kubeconfig --name "$k8sClusterName"
