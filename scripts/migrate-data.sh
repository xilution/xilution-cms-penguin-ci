#!/bin/bash

set -x

organizationId=${1}
penguinPipelineId=${2}
sourceStageName=${3}
targetStageName=${4}
jobId=$(uuidgen)

cat <<EOF >./migrate-job.yaml
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    jobId: "$jobId"
    organizationId: "$organizationId"
    penguinPipelineId: "$penguinPipelineId"
    sourceStageName: "$sourceStageName"
    targetStageName: "targetStageName"
  name: "job-migrate-data-$jobId"
spec:
  backoffLimit: 4
  template:
    spec:
      containers:
      - command:
        - "./migrate.sh"
        - "./data/wordpress-${penguinPipelineId}-${sourceStageName}"
        - "./data/wordpress-${penguinPipelineId}-${targetStageName}"
        image: docker.io/xilution/xilution-cms-penguin-docker:latest
        name: migrate-data
        volumeMounts:
        - mountPath: "/etc/penguin/data"
          name: persistent-storage
      imagePullSecrets:
      - name: regcred
      restartPolicy: Never
      volumes:
      - name: persistent-storage
        persistentVolumeClaim:
          claimName: wp-efs-claim
  ttlSecondsAfterFinished: 120
EOF
kubectl apply -f migrate-job.yaml
rm -rf migrate-job.yaml
