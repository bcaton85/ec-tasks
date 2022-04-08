# ec-tasks

## Overview

Task definitions related to HACBS Enterprise Contract. 

## How it works

The main entry-point of the repository is the `/scripts/run.sh` script. Details on how to run the script is in the `How to run` section.

The execution is as follows:
- `/scripts/run.sh` is ran
- If `BUILD` is set to `true` run the `/scripts/build-and-push.sh` script
  - This will rebuild the image in `/ec-image` which will be used by the contract task
  - The image will be pushed to repo set by `TASK_IMAGE`
  - The contract task in `/tasks` will be bundled and pushed to the repo set by `BUNDLE_IMAGE`
- Create the OCP service account used to run the contract task and give it permissions 
- Run the `PipelineRun` referencing the contract task in `/scripts/ocp/enterprise-contract-pipelinerun.yaml`

## How to run

- The scripts assume the use of Quay. Create two repositories in Quay; one that will hold the image that will be ran by the contract task and another that will hold the Tekton bundle containing the contract task. For example, in my account `bcaton` I created the following repositories:
    - `quay.io/bcaton/enterprise-contract`
    - `quay.io/bcaton/enterprise-contract-bundle`
- For each of these repositories, create a service account and give it write permissions to the repository. Note the token associated with the service account since it will be used later.
- Execute the pipeline by running `/scripts/run.sh` and passing the `PipelineRun` name of the pipeline run to verify against. As an example:
    ```
    TASK_IMAGE=quay.io/bcaton/enterprise-contract:v0.0.0 \
    BUNDLE_IMAGE=quay.io/bcaton/enterprise-contract-bundle:v0.0.0 \
    QUAY_TOKEN=QUAY_SA_TOKEN \
    POLICY_REPO=https://github.com/bcaton85/ec-policies \
    POLICY_COMMIT=0ad94c212427d1be29340503fd4dc8e6f9b524a2 \
    BUILD=true \
    ./scripts/run.sh PIPELINE_RUN_NAME
    ```
    
    Detailed explanation of each variable:
    - `TASK_IMAGE`: Image registry where the contract image will be stored and retrieved
    - `BUNDLE_IMAGE`: Image registry where the contract task bundle will be stored and retrieved
    - `QUAY_TOKEN`: Service account token that has write access to the `TASK_IMAGE` and `BUNDLE_IMAGE` repos
    - `POLICY_REPO`: Github repository where the Rego policies should be pulled from
    - `POLICY_COMMIT`: Specific commit in the `POLICY_REPO` that the policies should be pulled from
    - `BUILD`: Either true or false, rebuild and push the contract image and contract task bundle
