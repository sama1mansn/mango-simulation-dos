#!/usr/bin/env bash
set -ex
echo ----- stage: checkout buildkite Steps Env ------ 
## mango_bench setup ENVS
[[ ! "$RUST_LOG" ]]&& RUST_LOG=info && echo RUST_LOG env not found, use $RUST_LOG
[[ ! "$ENDPOINT" ]]&& echo ENDPOINT env not found && exit 1
[[ ! "$DURATION" ]]&& echo DURATION env not found && exit 1
[[ ! "$QOUTES_PER_SECOND" ]]&& echo ENDPOINT env not found && exit 1
[[ ! "$ACCOUNTS" ]]&& ACCOUNTS="accounts-1_20.json accounts-2_20.json accounts-3_10.json" && echo ACCOUNTS not found, use $ACCOUNTS
[[ ! "$AUTHORITY_FILE" ]] && AUTHORITY_FILE=authority.json && echo AUTHORITY_FILE , use $AUTHORITY_FILE
[[ ! "$ID_FILE" ]] && ID_FILE=ids.json && echo ID_FILE , use $ID_FILE
## keeper_run run ENVS
[[ ! "$CLUSTER" ]] && KEEPER_CLUSTER=testnet && echo KEEPER_CLUSTER , use $KEEPER_CLUSTER
## mango-simulation build repo ENVS
[[ ! "$MANGO_SIMULATION_REPO" ]]&& MANGO_SIMULATION_REPO=https://github.com/solana-labs/mango-simulation.git && echo MANGO_SIMULATION_REPO env not found, use $MANGO_SIMULATION_REPO
[[ ! "$MANGO_SIMULATION_BRANCH" ]]&& MANGO_SIMULATION_BRANCH=main && echo MANGO_SIMULATION_BRANCH env not found, use $MANGO_SIMULATION_BRANCH
[[ ! "$MANGO_SIMULATION_DIR" ]]&& MANGO_SIMULATION_DIR=/home/sol/mango_simulation && echo MANGO_SIMULATION_DIR env not found, use $MANGO_SIMULATION_DIR
[[ ! "$RUN_KEEPER" ]] && RUN_KEEPER=true && echo no RUN_KEEPER , use $RUN_KEEPER
[[ ! "$MANGO_CONFIGURE_REPO" ]]&& MANGO_CONFIGURE_REPO=https://github.com/solana-labs/configure_mango.git && echo MANGO_CONFIGURE_REPO env not found, use $MANGO_CONFIGURE_REPO
[[ ! "$MANGO_CONFIGURE_DIR" ]] && MANGO_CONFIGURE_DIR=configure_mango && echo no MANGO_CONFIGURE_DIR , use $MANGO_CONFIGURE_DIR
## CI program ENVS
[[ ! "$GIT_TOKEN" ]]&& echo GIT_TOKEN env not found && exit 1
[[ ! "$GIT_REPO" ]]&& GIT_REPO=$BUILDKITE_REPO && GIT_REPO not found, use $GIT_REPO
[[ ! "$GIT_REPO_DIR" ]]&& GIT_REPO_DIR="mango-simulation-dos" && GIT_REPO_DIR not found, use $GIT_REPO_DIR
[[ ! "$NUM_CLIENT" || $NUM_CLIENT -eq 0 ]]&& echo NUM_CLIENT env invalid && exit 1
[[ ! "$AVAILABLE_ZONE" ]]&& echo AVAILABLE_ZONE env not found && exit 1
[[ ! "$SLACK_WEBHOOK" ]]&&[[ ! "$DISCORD_WEBHOOK" ]]&& echo no WEBHOOK found && exit 1
[[ ! "$KEEP_INSTANCES" ]]&& KEEP_INSTANCES="false" && echo KEEP_INSTANCES env not found, use $KEEP_INSTANCES
[[ ! "$MANGO_SIMULATION_PRIVATE_BUCKET" ]]&& MANGO_SIMULATION_PRIVATE_BUCKET="mango-simulation-private" && no MANGO_SIMULATION_PRIVATE_BUCKET use $MANGO_SIMULATION_PRIVATE_BUCKET
[[ ! "$ARTIFACT_BUCKET" ]]&& ARTIFACT_BUCKET="buildkite-dos-agent" && no MANGO_SIMULATION_PRIVATE_BUCKET use $ARTIFACT_BUCKET
[[ ! "$TERMINATION_CHECK_INTERVAL" ]]&& TERMINATION_CHECK_INTERVAL=30 && no TERMINATION_CHECK_INTERVAL use $TERMINATION_CHECK_INTERVAL

source utils.sh
echo ----- stage: prepare metrics env ------ 
[[ -f "dos-metrics-env.sh" ]]&& rm dos-metrics-env.sh
download_file "gs://$MANGO_SIMULATION_PRIVATE_BUCKET" dos-metrics-env.sh ./
[[ ! -f "dos-metrics-env.sh" ]]&& echo "NO dos-metrics-env.sh found" && exit 1

echo ----- stage: prepare ssh key to dynamic clients ------
download_file "gs://$MANGO_SIMULATION_PRIVATE_BUCKET" id_ed25519_dos_test ./
[[ ! -f "id_ed25519_dos_test" ]]&& echo "no id_ed25519_dos_test found" && exit 1
chmod 600 id_ed25519_dos_test

echo ----- stage: prepare env-artifact for clients ------
## Mango-simulation Envs
echo "RUST_LOG=$RUST_LOG" > env-artifact.sh
echo "ENDPOINT=$ENDPOINT" >> env-artifact.sh
echo "DURATION=$DURATION" >> env-artifact.sh
echo "QOUTES_PER_SECOND=$QOUTES_PER_SECOND" >> env-artifact.sh
echo "AUTHORITY_FILE=$AUTHORITY_FILE" >> env-artifact.sh
echo "ID_FILE=$ID_FILE" >> env-artifact.sh
echo "ACCOUNTS=\"$ACCOUNTS\"" >> env-artifact.sh
# Keeper Run Envs
echo "CLUSTER=$CLUSTER" >> env-artifact.sh
#mango-simulation build repo ENVS
echo "MANGO_SIMULATION_REPO=$MANGO_SIMULATION_REPO" >> env-artifact.sh
echo "MANGO_SIMULATION_BRANCH=$MANGO_SIMULATION_BRANCH" >> env-artifact.sh
echo "MANGO_SIMULATION_DIR=$MANGO_SIMULATION_DIR" >> env-artifact.sh
#mango-configuration build repo ENVS
echo "MANGO_CONFIGURE_REPO=$MANGO_CONFIGURE_REPO" >> env-artifact.sh
echo "MANGO_CONFIGURE_DIR=$MANGO_CONFIGURE_DIR" >> env-artifact.sh
## CI program ENVS
echo "GIT_TOKEN=$GIT_TOKEN" >> env-artifact.sh
echo "GIT_REPO=$GIT_REPO" >> env-artifact.sh
echo "GIT_REPO_DIR=$GIT_REPO_DIR" >> env-artifact.sh
echo "MANGO_SIMULATION_PRIVATE_BUCKET=$MANGO_SIMULATION_PRIVATE_BUCKET" >> env-artifact.sh
echo "NUM_CLIENT=$NUM_CLIENT" >> env-artifact.sh
echo "AVAILABLE_ZONE=\"$AVAILABLE_ZONE\"" >> env-artifact.sh
echo "SLACK_WEBHOOK=$SLACK_WEBHOOK" >> env-artifact.sh
echo "KEEP_INSTANCES=$KEEP_INSTANCES" >> env-artifact.sh
echo "TERMINATION_CHECK_INTERVAL=$TERMINATION_CHECK_INTERVAL" >> env-artifact.sh
# buildkite build envs
echo "BUILDKITE_PIPELINE_ID=$BUILDKITE_PIPELINE_ID" >> env-artifact.sh
echo "BUILDKITE_BUILD_ID=$BUILDKITE_BUILD_ID" >> env-artifact.sh
echo "BUILDKITE_JOB_ID=$BUILDKITE_JOB_ID" >> env-artifact.sh
echo "BUILDKITE_BUILD_NUMBER=$BUILDKITE_BUILD_NUMBER" >> env-artifact.sh
## artifact address
echo "ARTIFACT_BUCKET=$ARTIFACT_BUCKET" >> env-artifact.sh
echo "ENV_ARTIFACT_FILE=env-artifact.sh" >> env-artifact.sh
echo "MANGO_SIMULATION_ARTIFACT_FILE=mango-simulation" >> env-artifact.sh

cat dos-metrics-env.sh >> env-artifact.sh
exit 0
