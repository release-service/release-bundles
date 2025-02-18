#!/usr/bin/env bash

TASK_PATH="$1"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Add mocks to the beginning of task step script
yq -i '.spec.steps[0].script = load_str("'$SCRIPT_DIR'/mocks.sh") + .spec.steps[0].script' "$TASK_PATH"

# Create a dummy osidb secret (and delete it first if it exists)
# The secret name is hardcoded in the task so the mock secret name can't have the task name in it
kubectl delete secret osidb-service-account --ignore-not-found
kubectl create secret generic osidb-service-account --from-literal=name=myname --from-literal=base64_keytab=OWEyMmJmYzgtYzJkZi00Y2VhLWJkNWItYjMxNzYxZjFkM2M0Cg== --from-literal=osidb_url=myurl
