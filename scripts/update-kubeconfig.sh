#!/bin/bash -ex

k8sClusterName=${K8S_CLUSTER_NAME}

aws eks update-kubeconfig --name "$k8sClusterName"
