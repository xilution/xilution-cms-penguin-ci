#!/bin/bash

xilution_penguin_instance_id=$1

sleep 5

load_balancer_hostname=$(kubectl get services/wordpress-"${xilution_penguin_instance_id}" -n wordpress -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

# TODO - replace the following with a command that will add the load_balancer_hostname reference to the Xilution load balancer lookup table.
echo "$load_balancer_hostname"
