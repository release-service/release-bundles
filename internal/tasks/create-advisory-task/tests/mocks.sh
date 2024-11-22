#!/usr/bin/env bash
set -eux

# mocks to be injected into task step scripts
function git() {
  echo "Mock git called with: $*"

  if [[ "$*" == *"clone"* ]]; then
    gitRepo=$(echo "$*" | cut -f5 -d/ | cut -f1 -d.)
    mkdir -p "$gitRepo"/schema
    echo '{"$schema": "http://json-schema.org/draft-07/schema#","type": "object", "properties":{}}' > "$gitRepo"/schema/advisory.json
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
    echo Error: Unexpected call
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
