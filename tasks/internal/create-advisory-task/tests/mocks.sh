#!/usr/bin/env bash
set -eux

# mocks to be injected into task step scripts
function git() {
  echo "Mock git called with: $*"

  if [[ "$*" == *"clone"* ]]; then
    gitRepo=$(echo "$*" | cut -f5 -d/ | cut -f1 -d.)
    mkdir -p "$gitRepo"/schema
    echo '{"$schema": "http://json-schema.org/draft-07/schema#","type": "object", "properties":{}}' > "$gitRepo"/schema/advisory.json

  elif [[ "$*" == *"ls-tree"* ]]; then
    echo -e "1452\n1442"

  elif [[ "$*" == *"show origin/main"* ]]; then
    echo "Fetching advisory content for: $*" >&2
    advisory_num=$(echo "$*" | grep -oE 'advisories/data/advisories/(dev-tenant|failing-tenant)/2024/[0-9]{4,6}' | grep -oE '[0-9]{4,6}$')

    case "$advisory_num" in
      1442)
        echo "Returning advisory for 1442" >&2
        cat <<EOF
apiVersion: rhtap.redhat.com/v1alpha1
kind: Advisory
metadata:
  name: 2024:1442
spec:
  content:
    images:
      - architecture: amd64
        component: foo-foo-manager-1-15
        containerImage: quay.io/example/openstack@sha256:abde
        purl: pkg:oci/example@sha256:abcdef?repository_url=quay.io/example
        repository: quay.io/example/openstack
        signingKey: example-sign-key
        tags:
          - v1.0
          - latest
EOF
      ;;
      1452)
        echo "Returning advisory for 1452" >&2
        cat <<EOF
apiVersion: rhtap.redhat.com/v1alpha1
kind: Advisory
metadata:
  name: 2024:1452
spec:
  content:
    images:
      - architecture: amd64
        component: foo-foo-manager-1-15
        containerImage: quay.io/example/openstack@sha256:lmnop
        purl: pkg:oci/example@sha256:abcdef?repository_url=quay.io/example
        repository: quay.io/example/openstack
        signingKey: example-sign-key
        tags:
          - latest
EOF
      ;;
      *)
        echo "Error: Unexpected advisory number $advisory_num" >&2
        exit 1
      ;;
    esac

  elif [[ "$*" == *"failing-tenant"* ]]; then
    echo "Mocking failing git command" && false
  else
    # Mock the other git functions to pass
    : # no-op - do nothing
  fi
}

function glab() {
  echo "Mock glab called with: $*"

  if [[ "$*" != "auth login"* ]]; then
    echo "Error: Unexpected call"
    exit 1
  fi
}

function kinit() {
  echo "kinit $*"
}

function curl() {
  echo Mock curl called with: $* >&2

  if [[ "$*" == "--retry 3 --negotiate -u : https://errata/api/v1/advisory/reserve_live_id -XPOST" ]] ; then
    echo '{"live_id": 1234}'
  else
    echo Error: Unexpected call
    exit 1
  fi
}

function date() {
  echo Mock date called with: $* >&2

  case "$*" in
      *"+%Y-%m-%dT%H:%M:%SZ")
          echo "2024-12-12T00:00:00Z"
          ;;
      "*")
          echo Error: Unexpected call
          exit 1
          ;;
  esac
}

function kubectl() {
  # The default SA doesn't have perms to get configmaps, so mock the `kubectl get configmap` call
  if [[ "$*" == "get configmap create-advisory-test-cm -o jsonpath={.data.SIG_KEY_NAME}" ]]
  then
    echo key1
  else
    /usr/bin/kubectl $*
  fi
}
