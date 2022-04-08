#!/bin/bash
set -euo pipefail

# Required variables
PIPELINE_RUN_NAME=$1
BUNDLE_IMAGE=${BUNDLE_IMAGE}
BUILD=${BUILD:-true}

# Builds the image that will be used for the enterprise contract task
# Also bundles the enterprise contract task and pushes it to Quay
if [ "$BUILD" == "true" ]; then
    $(dirname $0)/build-and-push.sh
fi

# The enterprise task will need permissions to lookup the pipeline objects
oc apply -f $(dirname $0)/ocp/enterprise-contract-sa.yaml -n tekton-chains

# TODO: Simulating a enterprise contract configuration - not in use for now
echo "
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-config
data:
  # Can't put a list in a ConfigMap..?
  policy_config: |
    non_blocking_checks:
    - not_useful
" | kubectl apply -f -

# Update the pipelinerun with the latest bundle image containing the contract task
yq -i e '.spec.tasks[0].taskRef.bundle = strenv(BUNDLE_IMAGE)' $(dirname $0)/ocp/enterprise-contract-pipelinerun.yaml

# Using a pipelinerun file is required since tkn doesn't support referencing bundles yet
tkn pipeline start enterprise-contract \
  -p PIPELINE_RUN_NAME=$PIPELINE_RUN_NAME \
  -f $(dirname $0)/ocp/enterprise-contract-pipelinerun.yaml \
  --showlog
