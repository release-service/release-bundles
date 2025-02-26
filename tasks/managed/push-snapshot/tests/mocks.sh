#!/usr/bin/env bash
set -eux

function cosign() {
  echo Mock cosign called with: $*
  echo $* >> "$(workspaces.data.path)"/mock_cosign.txt
  if [[ "$*" == "copy -f registry.io/retry-image:tag "*":"* ]]; then
    if [[ "$(wc -l < "$(workspaces.data.path)/mock_cosign.txt")" -le 3 ]]; then
      echo Expected cosign call failure for retry test; return 1
    fi
  fi

  if [[ "$*" == "copy -f private-registry.io/image:tag "*":"* ]]
  then
    if [[ $(cat /etc/ssl/certs/ca-custom-bundle.crt) != "mycert" ]]
    then
      echo Custom certificate not mounted
      return 1
    fi
  fi

  if [[ "$*" != "copy -f "*":"*" "*":"* ]]
  then
    echo Error: Unexpected call
    exit 1
  fi
}

function skopeo() {
  echo Mock skopeo called with: $* >&2
  echo $* >> "$(workspaces.data.path)"/mock_skopeo.txt
  if [[ "$*" == "inspect --raw docker://registry.io/multiarch-test@sha256:xyz789" ]]; then
    echo '{"mediaType": "application/vnd.oci.image.index.v1+json", "manifests": [{"platform":{"os":"linux","architecture":"arm64"}}, {"platform":{"os":"linux","architecture":"amd64"}}]}'
    return
  elif [[ "$*" == "inspect --raw docker://"* ]]; then
    echo '{"mediaType": "my_media_type"}'
    return
  fi
  echo Error: Unexpected call; exit 1
}

function get-image-architectures() {
  if [[ "$1" == "registry.io/multiarch-test@sha256:xyz789" ]]; then
    echo '{"platform":{"architecture": "arm64", "os": "linux"}, "digest": "xyz789"}'
    echo '{"platform":{"architecture": "amd64", "os": "linux"}, "digest": "deadbeef"}'
  else
    echo '{"platform":{"architecture": "amd64", "os": "linux"}, "digest": "abcdefg"}'
    echo '{"platform":{"architecture": "ppc64le", "os": "linux"}, "digest": "deadbeef"}'
  fi
}

function select-oci-auth() {
  echo $* >> "$(workspaces.data.path)"/mock_select-oci-auth.txt
}

function oras() {
  echo $* >> "$(workspaces.data.path)"/mock_oras.txt
  if [[ "$*" == "resolve --registry-config "*" "* ]]; then
    if [[ "$*" =~ "--platform" && "$4" =~ ".src" ]]; then
      echo "Error: .src images should not use --platform" >&2
      exit 1
    fi
    if [[ "$4" == "registry.io/multiarch-test@sha256:xyz789" ]]; then
      echo "sha256:1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
    elif [[ "$4" == "registry.io/multiarch-test:sha256-1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef.src" ]]; then
      echo "sha256:0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba"
    elif [[ "$4" == "prod-registry.io/prod-location:sha256-1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef.src" ]]; then
      echo "sha256:0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba"
    elif [[ "$4" == "prod-registry.io/prod-location:multi-tag-source" ]]; then
      echo "sha256:0987654321fedcba0987654321fedcba0987654321fedcba0987654321fedcba"
    elif [[ "$4" == *skip-image*.src || "$4" == *skip-image*-source ]]; then
      echo "sha256:000000"
    elif [[ "$4" == *skip-image* ]]; then
      echo "sha256:111111"
    else
      # echo the shasum computed from the pull spec so the task knows if two images are the same
      echo -n "sha256:"
      echo $4 | sha256sum | cut -d ' ' -f 1
    fi
    return
  else
    echo Mock oras called with: $*
    echo Error: Unexpected call
    exit 1
  fi
}
