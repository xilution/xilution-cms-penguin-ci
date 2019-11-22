#!/bin/bash

export TILLER_NAMESPACE=tiller
tiller -listen=localhost:44134 -storage=secret -logtostderr &
echo $! > tiller.pid
sleep 5
export HELM_HOST=:44134
helm init --client-only

