#!/bin/bash

export_assume_role_credentials () {

  awsAccount=${1}
  awsRole=${2}

  aws sts assume-role \
    --role-arn arn:aws:iam::"$awsAccount":role/"$awsRole" \
    --role-session-name xilution-client-session >./aws-creds.json

  awsAccessKeyId=$(cat <./aws-creds.json | jq -r ".Credentials.AccessKeyId")
  export AWS_ACCESS_KEY_ID=$awsAccessKeyId
  awsSecretAccessKey=$(cat <./aws-creds.json | jq -r ".Credentials.SecretAccessKey")
  export AWS_SECRET_ACCESS_KEY=$awsSecretAccessKey
  awsSessionToken=$(cat <./aws-creds.json | jq -r ".Credentials.SessionToken")
  export AWS_SESSION_TOKEN=$awsSessionToken
}

export_skip_tests () {

  excludeStages=${1}
  theStage=${2}
  SKIP_TESTS=0

  for stage in $excludeStages
  do
    aStage=$(echo "$stage" | base64 --decode | tr '[:upper:]' '[:lower:]')
    if [[ "$aStage" == "$theStage" ]]
    then
      SKIP_TESTS=1
    fi
  done
  export SKIP_TESTS
}

export_load_balancer_hostname () {

  path=".status.loadBalancer.ingress[0].hostname"
  loadBalancerHostName=$(kubectl get services/ingress-nginx -n ingress-nginx -o json | jq -r "$path")

  export LOAD_BALANCER_HOSTNAME=$loadBalancerHostName
}

export_wordpress_site_url () {

  loadBalancerHostName=${1}
  penguinPipelineId=${2}
  stageName=${3}

  export WORDPRESS_SITE_URL="http://$loadBalancerHostName/wordpress/$penguinPipelineId/$stageName"
}

update_kubeconfig () {

  k8sClusterName=${1}

  aws eks update-kubeconfig --name "$k8sClusterName"
}

wait_for_site_to_be_ready () {

  wordpressSiteUrl=${1}
  count=0;
  sleepSeconds=5
  maxAttempts=60

  while [[ $(curl -s -o /dev/null -w '%{http_code}' "$wordpressSiteUrl") != "200" && "$count" < "$maxAttempts" ]]
  do
    sleep $sleepSeconds;
    count=$(count+1);
  done

  if [[ "$count" == "$maxAttempts" ]]
  then
    aws codebuild stop-build --id "$CODEBUILD_BUILD_ID";
  fi
}

execute_commands () {

  commands=${1}

  for command in $commands
  do
    echo "$command" | base64 --decode | bash
  done
}
