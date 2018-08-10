#!/bin/bash
set -eo pipefail

DOCKER_USER=$(vault kv get -format=json kv/docker | jq -r '.data.docker_user')
DOCKER_PASSWORD=$(vault kv get -format=json kv/docker | jq -r '.data.docker_password')

docker version
docker build --no-cache -t umccr/test-vault-secrets-injection .
echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USER" --password-stdin
docker push umccr/test-vault-secrets-injection
