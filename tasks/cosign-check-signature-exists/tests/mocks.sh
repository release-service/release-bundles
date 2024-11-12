#!/usr/bin/env bash
set -eux

function cosign() {
  if [ "$6" == "quay.io/redhat-pending/myproduct----myrepo:signed" ]; then
    echo -n '[{"critical":{"identity":{"docker-reference":"registry.stage.redhat.io/myproduct/myrepo:signed"},"image":{"docker-manifest-digest":"sha256:0000"}},"optional":null}]'
  else
    echo -n '[]'
  fi
}
