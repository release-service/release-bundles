#!/usr/bin/env bash

TASK_PATH="$1"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Add mocks to the beginning of task step script
yq -i '.spec.steps[0].script = load_str("'$SCRIPT_DIR'/mocks.sh") + .spec.steps[0].script' "$TASK_PATH"

kubectl delete secret update-manager-secret --ignore-not-found
kubectl create secret generic update-manager-secret --from-literal=token=abcdefghijk --from-literal=name=release-team --from-literal=email=release@domain.com
