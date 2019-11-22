#!/bin/bash

xilution_aws_region=$1
xilution_aws_profile=$2

aws eks update-kubeconfig --region "${xilution_aws_region}" --name xilution-k8s --profile "${xilution_aws_profile}"
