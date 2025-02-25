#!/usr/bin/env bash
set -eux

# mocks to be injected into task step scripts

function cosign() {
  echo Mock cosign called with: $*
  echo $* >> $(workspaces.data.path)/mock_cosign.txt

  if [[ "$*" != "download sbom --output-file myImageID"[1-5]*".json imageurl"[1-5] && \
     "$*" != "download sbom --output-file myImageID"[1-5]*".json --platform linux/"*" multiarch-"[1-5] ]]
  then
    echo Error: Unexpected call
    exit 1
  fi

  if [[ "$4" == *cyclonedx.json ]]; then
    SBOM_JSON='{"bomFormat": "CycloneDX"}'
  else
    SBOM_JSON='{"spdxVersion": "SPDX-2.3"}'
  fi

  echo "$SBOM_JSON" > /workspace/data/downloaded-sboms/${4}
}

function upload_rpm_data() {
  echo Mock upload_rpm_data called with: $*
  echo $* >> "$(workspaces.data.path)/mock_upload_rpm_data.txt"

  if [[ "$*" != "--retry --image-id "*" --sbom-path "*".json --verbose" ]]
  then
    echo Error: Unexpected call
    exit 1
  fi

  if [[ "$3" == myImageID1Failing ]]
  then
    echo "Simulating a failing RPM data push..."
    return 1
  fi

  if [[ "$3" == myImageID?Parallel ]]
  then
    LOCK_FILE=$(workspaces.data.path)/${3}.lock
    touch $LOCK_FILE
    sleep 2
    LOCK_FILE_COUNT=$(ls $(workspaces.data.path)/*.lock | wc -l)
    echo $LOCK_FILE_COUNT > $(workspaces.data.path)/${3}.count
    sleep 2
    rm $LOCK_FILE
  fi
}

function upload_rpm_data_cyclonedx() {
  echo Mock upload_rpm_data_cyclonedx called with: $*
  echo $* >> "$(workspaces.data.path)/mock_upload_rpm_data_cyclonedx.txt"

  if [[ "$*" != "--retry --image-id "*" --sbom-path "*".json --verbose" ]]
  then
    echo Error: Unexpected call
    exit 1
  fi
}

function select-oci-auth() {
  echo $* >> $(workspaces.data.path)/mock_select-oci-auth.txt
}
