#!/bin/bash -e
set -e
set -0 pipefail

APP=$1

# install DataDog Python library
pip install datadog

DATADOG_API_KEY=$(vault kv get -format=json kv/datadog | jq -r '.data.api_key')
DATADOG_APP_KEY=$(vault kv get -format=json kv/datadog | jq -r '.data.app_key')

# Set up
tee ~/.dogrc << END
[Connection]
apikey = ${DATADOG_API_KEY}
appkey = ${DATADOG_APP_KEY}
END


echo "Testing DataDog event generation"
dog event post --no_host --tags aws,ami,$APP --type travis "New $APP event created" "New DataDog event created for $TRAVIS_COMMIT in umccr/test-vault-secrets-injection"
echo "Event successfully sent."
