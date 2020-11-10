#!/bin/bash -ex

set -x

organizationId=${1}
penguinPipelineId=${2}
stageName=${3}
sourceDir=${4}

cd "$sourceDir" || false

seedDetails=$(jq -r ".data.seed[]? | @base64" <./xilution.json)

for detail in $seedDetails; do
  source=$(echo "$detail" | base64 --decode | jq -r ".source")
  target=$(echo "$detail" | base64 --decode | jq -r ".target")
  jobId=$(uuidgen)

  cat <<EOF >./seed-job.yaml
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    jobId: "$jobId"
    organizationId: "$organizationId"
    penguinPipelineId: "$penguinPipelineId"
    stageName: "$stageName"
  name: "job-seed-data-$jobId"
spec:
  backoffLimit: 4
  template:
    spec:
      containers:
      - command:
        - "./seed.sh"
        - "${source}"
        - "./${target}"
        image: docker.io/xilution/xilution-cms-penguin-docker:latest
        name: seed-data
        volumeMounts:
        - mountPath: "/etc/penguin/${target}"
          name: persistent-storage
          subPath: "wordpress-${penguinPipelineId}-${stageName}/${target}"
      imagePullSecrets:
      - name: regcred
      restartPolicy: Never
      volumes:
      - name: persistent-storage
        persistentVolumeClaim:
          claimName: wp-efs-claim
  ttlSecondsAfterFinished: 120
EOF
  kubectl apply -f seed-job.yaml
  rm -rf seed-job.yaml
done
