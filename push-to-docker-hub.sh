#!/bin/bash
set -eo pipefail

# expect to get the docker image name provided
DOCKER_IMAGE=$1

DOCKER_USER=$(vault kv get -format=json kv/docker | jq -r '.data.docker_user')
DOCKER_PASSWORD=$(vault kv get -format=json kv/docker | jq -r '.data.docker_password')

if [[ "$TRAVIS_BRANCH" =~ [0-9]\.[0-9]+(\.[0-9]+)?(-[A-Za-z0-9_])? ]]; then
  DOCKER_TAG="$DOCKER_IMAGE:$TRAVIS_BRANCH"
else
  DOCKER_TAG="$DOCKER_IMAGE:latest"
fi
echo "Building $DOCKER_TAG"

docker version
docker build --no-cache -t "$DOCKER_TAG" .

echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USER" --password-stdin
docker push "$DOCKER_TAG"
