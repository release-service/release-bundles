#!/usr/bin/env bash
set -eux

count_file="/tmp/request-signature-failure-count.txt"
if [[ ! -f "$count_file" ]]; then
    echo "0" > "$count_file"
fi


function ssh() {
    # Read the current ssh_call_count from the file
    ssh_call_count=$(cat "$count_file")
    ssh_call_count=$((ssh_call_count + 1))
    echo "$ssh_call_count" > "$count_file"

    echo "$ssh_call_count" > "$(workspaces.data.path)/ssh_calls.txt"
}

function pubtools-sign-msg-container-sign() {
  >&2 echo "Mock pubtools-sign-msg-container-sign called with: $*"
  echo "$*" >> "/tmp/mock_pubtools-sign.txt"
  out=$(sed -n '1p' "$(workspaces.data.path)/mocked_signing_response")
  sed -i '1d' "$(workspaces.data.path)/mocked_signing_response"
  echo "$out"
}


function mock_pubtools_sign_msg_container_sign() {
  echo "mock call"
}

function pubtools-pyxis-upload-signatures() {
  >&2 echo "Mock pubtools-pyxis-upload-signatures called with: $*"
  echo "$*" >> "$(workspaces.data.path)/mock_pubtools-pyxis-upload-signatures.txt"
}
