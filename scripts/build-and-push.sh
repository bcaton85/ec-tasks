#!/bin/bash
set -euo pipefail

# Lifting up required variables - sensible defaults will be set for these later
TASK_IMAGE=${TASK_IMAGE}
BUNDLE_IMAGE=${BUNDLE_IMAGE}
POLICY_REPO=${POLICY_REPO}
POLICY_COMMIT=${POLICY_COMMIT}
QUAY_TOKEN=${QUAY_TOKEN}

# Build the enterprise contract image that will be used by the task
# Dockerfile will pull the policies from the policy repo by commit
podman build $(dirname $0)/../ec-image \
    --build-arg POLICY_REPO=$POLICY_REPO \
    --build-arg POLICY_COMMIT=$POLICY_COMMIT \
    -t $TASK_IMAGE

podman push $TASK_IMAGE

# Update the enterprise task with the new enterprise contract image
yq -i e '.spec.steps[0].image = strenv(TASK_IMAGE)' $(dirname $0)/../tasks/enterprise-contract.yaml

# Bundle the task and push it to $BUNDLE_IMAGE
tkn bundle push $BUNDLE_IMAGE \
    -f $(dirname $0)/../tasks/enterprise-contract.yaml \
    --remote-bearer="$QUAY_TOKEN"
