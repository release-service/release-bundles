#!/usr/bin/env bash
set -eux

# mocks to be injected into task step scripts
curl() {
  # Output the call to stderr
  echo "Mock curl called with:" "$@" >&2
  workdir="$(workspaces.data.path)/workdir"
  echo "$@" >> "$workdir/mock_curl.txt"

  # Throw a failure (which should be caught) for Atlas API calls in the curl fail test
  params="$*"
  if [[ "$params" =~ "https://sbom.atlas.devshift.net/api/v1/sbom?id=spdx_minimal_curl_fail_2_3" ]]; then
    return 1
  fi
}
