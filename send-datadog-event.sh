#!/bin/bash -e
set -e
set -o pipefail

APP=$1
TAGS=$2

# install DataDog Python library
pip install datadog

export VAULT_ADDR=$VAULT_ADDR_DEV
export VAULT_TOKEN=$VAULT_TOKEN_DEV

DATADOG_API_KEY=$(vault kv get -format=json kv/datadog | jq -r '.data.api_key')
DATADOG_APP_KEY=$(vault kv get -format=json kv/datadog | jq -r '.data.app_key')

# Set up
cat > ~/.dogrc << END
[Connection]
apikey = ${DATADOG_API_KEY}
appkey = ${DATADOG_APP_KEY}
END


echo "Generating DataDog event"
event_txt="$TRAVIS_REPO_SLUG: new build (no [$TRAVIS_BUILD_NUMBER](https://travis-ci.org/umccr/test-vault-secrets-injection/builds/$TRAVIS_BUILD_ID)) on branch $TRAVIS_BRANCH succeeded for commit [${TRAVIS_COMMIT:0:12}](https://github.com/umccr/test-vault-secrets-injection/commit/${TRAVIS_COMMIT:0:12})"
dog event post --no_host --tags $TAGS --type travis "New $APP event created" "$event_text"
echo "Event successfully sent."
