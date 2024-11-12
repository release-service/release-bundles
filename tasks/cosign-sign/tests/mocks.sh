#!/usr/bin/env bash
set -eux

function cosign() {
  echo "Signing image with args $*"
  touch "$(workspaces.data.path)/cosign_calls.txt"
  echo "cosign $*" > "$(workspaces.data.path)/cosign_calls.txt"
}
