#!/bin/bash

# This script will run task tests for all task directories
# provided either via TEST_ITEMS env var, or as arguments
# when running the script.
#
# Requirements:
# - Connection to a running k8s cluster (e.g. kind)
# - Tekton installed on the cluster
# - tkn installed
#
# Examples of usage:
# export TEST_ITEMS="mydir/tasks/apply-mapping some/other/dir"
# ./test_tekton_tasks.sh
#
# or
#
# ./test_tekton_tasks.sh mydir/tasks/apply-mapping some/other/dir

# yield empty strings for unmatched patterns
shopt -s nullglob

WORKSPACE_TEMPLATE=${BASH_SOURCE%/*/*}/resources/workspace-template.yaml

if [ -z "${USE_TRUSTED_ARTIFACTS}" ]
then
  #echo "Warning: env variable TRUSTED_ARTIFACT_OCI_STORAGE not defined"
  #echo ""
  #echo "It must point to a location in quay where trusted artifacts will be placed."
  #echo "for example: TRUSTED_ARTIFACT_OCI_STORAGE=quay.io/konflux-test-data/trusted-artifacts"
  #echo ""
  echo "Defaulting to PVC based workspaces..."
  # empty is needed since trusted-artifacts needs a non-empty storage
  # parameter in order to reach the skipping logic
  export TRUSTED_ARTIFACT_OCI_STORAGE="empty"
else

  echo "Using Trusted Artifacts for workspaces..."
  export TRUSTED_ARTIFACT_OCI_STORAGE=registry-service.kind-registry/trusted-artifacts
  export TRUSTED_ARTIFACT_OCI_DOCKER_CONFIG_JSON_PATH=/tmp/.dockerconfig.json

  kubectl create secret generic docker-config \
    --from-file=.dockerconfigjson="${TRUSTED_ARTIFACT_OCI_DOCKER_CONFIG_JSON_PATH}" \
    --type=kubernetes.io/dockerconfigjson --dry-run=client -o yaml | kubectl apply -f -
  kubectl patch serviceaccount default -p \
    '{"imagePullSecrets": [{"name": "docker-config"}], "secrets": [{"name": "docker-config"}]}'

fi

#  if [ -z "${TRUSTED_ARTIFACT_OCI_DOCKER_CONFIG_JSON_PATH}" ]
#  then
#    echo "Error: env variable TRUSTED_ARTIFACT_OCI_DOCKER_CONFIG_JSON_PATH not defined"
#    echo ""
#    echo "It must point to a dockerconfig json file that contains the credentials to push and pull"
#    echo "trusted artifacts from TRUSTED_ARTIFACT_OCI_STORAGE = ${TRUSTED_ARTIFACT_OCI_STORAGE}"
#    echo ""
#    echo "The file should resemble:
#    {
#      \"auths\": {
#        \"quay.io\": {
#          \"auth\": \"<base64 encoded string of user:password>\"
#        }
#      }
#    }
#    "
#    exit 1
#  fi
#
#  if [ ! -f "${TRUSTED_ARTIFACT_OCI_DOCKER_CONFIG_JSON_PATH}" ]
#  then
#    echo "Error: ${TRUSTED_ARTIFACT_OCI_DOCKER_CONFIG_JSON_PATH} not found"
#    echo ""
#    echo "The file must contain dockerconfig json file that contains the credentials to push and pull"
#    echo "trusted artifacts from TRUSTED_ARTIFACT_OCI_STORAGE = ${TRUSTED_ARTIFACT_OCI_STORAGE}"
#    echo ""
#    echo "The file should resemble:
#    {
#      \"auths\": {
#        \"quay.io\": {
#          \"auth\": \"<base64 encoded string of user:password>\"
#        }
#      }
#    }
#    "
#    exit 1
#  fi

if [ $# -gt 0 ]
then
  TEST_ITEMS=$@
fi

if [ -z "${TEST_ITEMS}" ]
then
  echo Error: No task directories.
  echo Usage:
  echo "$0 [item1] [item2] [...]"
  echo
  echo or
  echo
  echo "export TEST_ITEMS=\"item1 item2 ...\""
  echo "$0"
  echo
  echo Items can be task directories or paths to task test yaml files
  echo "(useful when working on a single test)"
  exit 1
fi

# Check that all directories exist. If not, fail
for ITEM in $TEST_ITEMS
do
  if [[ "$ITEM" == *tests/test-*.yaml && -f "$ITEM" ]]; then
    true
  elif [[ -d "$ITEM" ]]; then
    true
  else
    echo "Error: Invalid file or directory: $ITEM"
    exit 1
  fi
done

for ITEM in $TEST_ITEMS
do
  echo Task item: $ITEM
  TASK_NAME=$(echo $ITEM | cut -d '/' -f 3)
  TASK_DIR=$(echo $ITEM | cut -d '/' -f -3)
  echo "  Task name: $TASK_NAME"

  TASK_PATH=${TASK_DIR}/${TASK_NAME}.yaml
  if [ ! -f $TASK_PATH ]
  then
    echo Error: Task file does not exist: $TASK_PATH
    exit 1
  fi

  TESTS_DIR=${TASK_DIR}/tests
  if [ ! -d $TESTS_DIR ]
  then
    echo Error: tests dir does not exist: $TESTS_DIR
    exit 1
  fi

  if [[ "$ITEM" == *tests/test-*.yaml ]]; then
    TEST_PATHS=($ITEM)
  else
    TEST_PATHS=($TESTS_DIR/test*.yaml)
  fi
  if [ ${#TEST_PATHS[@]} -eq 0 ]
  then
    echo "  Warning: No tests. Skipping..."
    continue
  fi

  # Use a copy of the task file to prevent modifying to original task file
  TASK_COPY=$(mktemp)
  cp "$TASK_PATH" "$TASK_COPY"

  if [ -f ${TESTS_DIR}/pre-apply-task-hook.sh ]
  then
    echo Found pre-apply-task-hook.sh file in dir: $TESTS_DIR. Executing...
    ${TESTS_DIR}/pre-apply-task-hook.sh "$TASK_COPY"
  fi

  echo "  Installing task"
  kubectl apply -f "$TASK_COPY"

  rm -f "$TASK_COPY"

  for TEST_PATH in ${TEST_PATHS[@]}
  do
    echo "  Installing test pipeline: $TEST_PATH"
    kubectl apply -f $TEST_PATH
    TEST_NAME=$(yq '.metadata.name' $TEST_PATH)

    # Sometimes the pipeline is not available immediately
    while ! kubectl get pipeline $TEST_NAME > /dev/null 2>&1
    do
      echo "  Pipeline $TEST_NAME not ready. Waiting 5s..."
      sleep 5
    done

    if [ -z "${USE_TRUSTED_ARTIFACTS}" ]; then
      workSpaceParams="volumeClaimTemplateFile=$WORKSPACE_TEMPLATE"
    else
      workSpaceParams="emptyDir="""
    fi
    PIPELINERUN=$(tkn p start $TEST_NAME -p ociStorage=${TRUSTED_ARTIFACT_OCI_STORAGE} -w "name=tests-workspace,${workSpaceParams}" -o json | jq -r '.metadata.name')

    echo "  Started pipelinerun $PIPELINERUN"
    sleep 1  # allow a second for the pr object to appear (including a status condition)
    while [ "$(kubectl get pr $PIPELINERUN -o=jsonpath='{.status.conditions[0].status}')" == "Unknown" ]
    do
      echo "  PipelineRun $PIPELINERUN in progress (status Unknown). Waiting for update..."
      sleep 5
    done
    tkn pr logs $PIPELINERUN

    PR_STATUS=$(kubectl get pr $PIPELINERUN -o=jsonpath='{.status.conditions[0].status}')

    ASSERT_TASK_FAILURE=$(yq '.metadata.annotations.test/assert-task-failure' < $TEST_PATH)
    if [ "$ASSERT_TASK_FAILURE" != "null" ]
    then
      if [ "$PR_STATUS" == "True" ]
      then
        echo "  Pipeline $TEST_NAME succeeded but was expected to fail"
        exit 1
      else
        echo "  Pipeline $TEST_NAME failed (expected). Checking that it failed in task ${ASSERT_TASK_FAILURE}..."

        # Check that the pipelinerun failed on the tested task and not somewhere else
        TASKRUN=$(kubectl get pr $PIPELINERUN -o json|jq -r ".status.childReferences[] | select(.pipelineTaskName == \"${ASSERT_TASK_FAILURE}\") | .name")
        if [ -z "$TASKRUN" ]
        then
          echo "    Unable to find task $ASSERT_TASK_FAILURE in childReferences of pipelinerun $PIPELINERUN. Pipelinerun failed earlier?"
          exit 1
        else
          echo "    Found taskrun $TASKRUN"
        fi
        if [ $(kubectl get tr $TASKRUN -o=jsonpath='{.status.conditions[0].status}') != "False" ]
        then
          echo "    Taskrun did not fail - pipelinerun failed later on?"
          exit 1
        else
          echo "    Taskrun failed as expected"
        fi

      fi
    else
      if [ "$PR_STATUS" == "True" ]
      then
        echo "  Pipelinerun $TEST_NAME succeeded"
      else
        echo "  Pipelinerun $TEST_NAME failed"
        exit 1
      fi
    fi

    echo
  done

done
