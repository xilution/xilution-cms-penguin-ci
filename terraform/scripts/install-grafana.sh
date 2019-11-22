#!/bin/bash

# reference: https://medium.com/@at_ishikawa/install-prometheus-and-grafana-by-helm-9784c73a3e97

helm install stable/grafana \
  --name grafana \
  --namespace monitoring
