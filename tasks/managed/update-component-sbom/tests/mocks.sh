#!/usr/bin/env bash
set -eux

function update_component_sbom() {
  echo Mock update_component_sbom called with: "$*"
  echo "$*" >> "$(workspaces.data.path)/mock_update.txt"

  if [[ "$*" != "--data-path $(workspaces.data.path)/data.json --input-path $(workspaces.data.path)/downloaded-sboms --output-path $(workspaces.data.path)/downloaded-sboms" ]]
  then
    echo Error: Unexpected call
    exit 1
  fi
}
