#!/bin/bash

# reference: https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html

helm install stable/prometheus \
  --name prometheus \
  --namespace monitoring \
  --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"
