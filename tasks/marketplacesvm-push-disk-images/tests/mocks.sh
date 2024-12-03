#!/usr/bin/env bash
set -eux

# mocks to be injected into task step scripts
function select-oci-auth() {
    echo Mock select-oci-auth called with: $*
    echo $* > "$(workspaces.data.path)/mock_select-oci-auth.txt"
}

function oras() {
    echo Mock oras called with: $*
    echo $* > "$(workspaces.data.path)/mock_oras.txt"

    if [[ "$*" != "pull --registry-config"* ]]; then
        echo Error: Unexpected call to oras
        exit 1
    fi
}

function marketplacesvm_push_wrapper() {
  echo Mock imarketplacesvm_push_wrapper called with: $*
  echo $* > "$(workspaces.data.path)/mock_wrapper.txt"

  /home/pubtools-marketplacesvm-wrapper/marketplacesvm_push_wrapper "$@" --dry-run

  if ! [[ "$?" -eq 0 ]]; then
      echo Unexpected call to marketplacesvm_push_wrapper
      exit 1
  fi
}

