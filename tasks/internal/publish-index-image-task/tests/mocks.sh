#!/usr/bin/env bash
set -x

# mocks to be injected into task step scripts

function skopeo() {
  echo Mock skopeo called with: $* >&2

  if [[ "$*" == *"--src-tls-verify=false --src-creds source docker://quay.io/source"* ]]
  then
    return 0
  elif [[ "$*" == *"--src-tls-verify=false docker://registry-proxy.engineering.redhat.com/foo"* ]]
  then
    return 0
  elif [[ "$*" == *"--src-tls-verify=false docker://registry-proxy.engineering.redhat.com/fail"* ]]
  then
    return 1
  else
    echo Error: Unexpected call
    exit 1
  fi
}
