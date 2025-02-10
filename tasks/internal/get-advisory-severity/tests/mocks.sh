#!/usr/bin/env sh
set -eux

# mocks to be injected into task step scripts

function kinit() {
  echo "kinit $*"
}

function curl() {
  echo Mock curl called with: $* >&2

  if [[ "$*" == "--retry 3 --negotiate -u : myurl/auth/token" ]]
  then
    echo '{"access": "dummy-token"}'
  elif [[ "$*" == *"myurl/osidb/api/v1/flaws?cve_id=CVE-critical"* ]]
  then
    echo '{"results": [{"impact":"CRITICAL","affects":[{"ps_component":"component","impact":""}]}]}'
  elif [[ "$*" == *"myurl/osidb/api/v1/flaws?cve_id=CVE-moderate"* ]]
  then
    echo '{"results": [{"impact":"MODERATE","affects":[{"ps_component":"component","impact":"IMPORTANT"},{"ps_component":"foo","impact":"LOW"}]}]}'
  else
    echo Error: Unexpected call
    exit 1
  fi
}
