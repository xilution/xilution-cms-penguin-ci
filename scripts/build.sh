#!/bin/bash -e

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}
commitId=${COMMIT_ID}

currentDir=$(pwd)
cd "${sourceDir}" || false

export dockerHubAccountName=$(jq -r ".dockerHub.account" <./xilution.json)
export dockerHubRepoName=$(jq -r ".dockerHub.repository" <./xilution.json)

docker build -t xilution/"${dockerHubRepoName}" "${sourceDir}"

docker tag "${dockerHubAccountName}"/"${dockerHubRepoName}" "${dockerHubAccountName}"/"${dockerHubRepoName}":"${commitId}"
docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"
docker push "${dockerHubAccountName}"/"${dockerHubRepoName}"

cd "${currentDir}" || false

cat <<EOF >image.yaml
wordpress:
  image:
    repository: $dockerHubAccountName/$dockerHubRepoName
    tag: $imageVersion
EOF
