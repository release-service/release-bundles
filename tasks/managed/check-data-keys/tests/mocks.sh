#mocks.sh
#!/usr/bin/env bash
set -eux
function curl() {
    if [[ "$*" == *"https://raw.githubusercontent.com/konflux-ci/release-service-catalog/refs/heads/production/schema/non-existent-schema.json"* ]]; then
        command curl -Ls --fail-with-body "$@" -o /tmp/schema
    else
        command curl -Ls --fail-with-body "$3" -o /tmp/schema
    fi
}
