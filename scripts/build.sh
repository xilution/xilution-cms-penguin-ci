#!/bin/bash -ex

sourceDir=${CODEBUILD_SRC_DIR_SourceCode}

currentDir=$(pwd)
cd "${sourceDir}" || false

export dockerHubAccountName=$(jq -r ".dockerHub.account" <./xilution.yaml)
export dockerHubRepoName=$(jq -r ".dockerHub.repository" <./xilution.yaml)
export imageVersion=$(jq -r ".version" <./xilution.yaml)

docker build -t xilution/"${dockerHubRepoName}" "${sourceDir}"

docker tag "${dockerHubAccountName}"/"${dockerHubRepoName}" "${dockerHubAccountName}"/"${dockerHubRepoName}":"${imageVersion}"
docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"
docker push "${dockerHubAccountName}"/"${dockerHubRepoName}"

cat <<EOF >image.yaml
wordpress:
  image:
    repository: $dockerHubAccountName/$dockerHubRepoName
    tag: $imageVersion
EOF

cd "${currentDir}" || false