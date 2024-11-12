#!/usr/bin/env bash
#
# Create a dummy cosignSecretName secret (and delete it first if it exists)
kubectl delete secret test-cosign-check-signature-exists-secrets --ignore-not-found

kubectl create secret generic test-cosign-check-signature-exists-secrets \
  --from-literal=REKOR_URL=https://fake-rekor-server \
  --from-literal=AWS_DEFAULT_REGION=us-test-1\
  --from-literal=AWS_ACCESS_KEY_ID=test-access-key\
  --from-literal=AWS_SECRET_ACCESS_KEY=test-secret-access-key\
  --from-literal=SIGN_KEY=aws://arn:mykey\
  --from-literal=PUBLIC_KEY=public-key

# Add mocks to the beginning of task step script
TASK_PATH="$1"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
yq -i '.spec.steps[0].script = load_str("'$SCRIPT_DIR'/mocks.sh") + .spec.steps[0].script' "$TASK_PATH"
