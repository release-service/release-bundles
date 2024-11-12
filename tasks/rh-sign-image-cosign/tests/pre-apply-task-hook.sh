#!/usr/bin/env bash
#
# Install the CRDs so we can create/get them
.github/scripts/install_crds.sh

# Add RBAC so that the SA executing the tests can retrieve CRs
kubectl apply -f .github/resources/crd_rbac.yaml

# delete old InternalRequests
kubectl delete internalrequests --all -A

# Create a dummy cosignSecretName secret (and delete it first if it exists)
kubectl delete secret test-cosign-secret test-cosign-secret-rekor --ignore-not-found
#
# Delete pipeline for signing
kubectl delete pipeline/cosign-signing-pipeline --ignore-not-found

cat > "/tmp/cosign-signing-pipeline.json" << EOF
{
  "apiVersion": "tekton.dev/v1",
  "kind": "Pipeline",
  "metadata": {
    "name": "cosign-signing-pipeline",
    "namespace": "default"
  },
  "spec": {
    "tasks": [
      {
        "name": "task1",
        "taskSpec": {
          "steps": [
            {
              "image": "bash:3.2",
              "name": "build",
              "script": "echo scott"
            }
          ]
        }
      }
    ]
  }
}
EOF
kubectl create -f /tmp/cosign-signing-pipeline.json

# Add mocks to the beginning of task step script
TASK_PATH="$1"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
yq -i '.spec.steps[0].script = load_str("'$SCRIPT_DIR'/mocks.sh") + .spec.steps[0].script' "$TASK_PATH"
