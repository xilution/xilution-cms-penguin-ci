#!/bin/bash -e

set -x

organizationId=${XILUTION_ORGANIZATION_ID}
penguinPipelineId=${PENGUIN_PIPELINE_ID}
stageName=${STAGE_NAME}
sourceDir=${CODEBUILD_SRC_DIR_SourceCode}

cd "$sourceDir" || false

seedMappings=$(jq -r ".data.seed.mappings[]? | @base64" <./xilution.json)

for seedMapping in $seedMappings; do
  source=$(echo "$seedMapping" | base64 --decode | jq -r ".source")
  target=$(echo "$seedMapping" | base64 --decode | jq -r ".target")
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
