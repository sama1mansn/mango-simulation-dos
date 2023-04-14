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
[[ ! "$MANGO_CONFIGURE_REPO" ]]&& MANGO_CONFIGURE_REPO=https://github.com/solana-labs/configure_mango.git && echo MANGO_CONFIGURE_REPO env not found, use $MANGO_CONFIGURE_REPO
[[ ! "$MANGO_CONFIGURE_BRANCH" ]]&& MANGO_CONFIGURE_BRANCH=main && echo MANGO_CONFIGURE_BRANCH env not found, use $MANGO_CONFIGURE_BRANCH
[[ ! "$MANGO_SIMULATION_DIR" ]]&& MANGO_SIMULATION_DIR=/home/sol/mango_simulation && echo MANGO_SIMULATION_DIR env not found, use $MANGO_SIMULATION_DIR
[[ ! "$MANGO_CONFIGURE_DIR" ]]&& MANGO_CONFIGURE_DIR=/home/sol/configure_mango && echo MANGO_CONFIGURE_COMMIT env not found, use $MANGO_CONFIGURE_DIR
## CI program ENVS
[[ ! "$GIT_TOKEN" ]]&& echo GIT_TOKEN env not found && exit 1
[[ ! "$GIT_REPO" ]]&& GIT_REPO=$BUILDKITE_REPO && GIT_REPO not found, use $GIT_REPO
[[ ! "$NUM_CLIENT" || $NUM_CLIENT -eq 0 ]]&& echo NUM_CLIENT env invalid && exit 1
[[ ! "$AVAILABLE_ZONE" ]]&& echo AVAILABLE_ZONE env not found && exit 1
[[ ! "$SLACK_WEBHOOK" ]]&&[[ ! "$DISCORD_WEBHOOK" ]]&& echo no WEBHOOK found && exit 1
[[ ! "$KEEP_INSTANCES" ]]&& KEEP_INSTANCES="false" && echo KEEP_INSTANCES env not found, use $KEEP_INSTANCES

source utils.sh
echo ----- stage: prepare metrics env ------ 
[[ -f "dos-metrics-env.sh" ]]&& rm dos-metrics-env.sh
download_file dos-metrics-env.sh
[[ ! -f "dos-metrics-env.sh" ]]&& echo "NO dos-metrics-env.sh found" && exit 1

echo ----- stage: prepare ssh key to dynamic clients ------
download_file id_ed25519_dos_test
[[ ! -f "id_ed25519_dos_test" ]]&& echo "no id_ed25519_dos_test found" && exit 1
chmod 600 id_ed25519_dos_test

echo ----- stage: prepare env-artifact for clients ------
## Mango-simulation Envs
echo "export RUST_LOG=$RUST_LOG" > env-artifact.sh
echo "export ENDPOINT=$ENDPOINT" >> env-artifact.sh
echo "export DURATION=$DURATION" >> env-artifact.sh
echo "export QOUTES_PER_SECOND=$QOUTES_PER_SECOND" >> env-artifact.sh
echo "export AUTHORITY_FILE=$AUTHORITY_FILE" >> env-artifact.sh
echo "export ID_FILE=$ID_FILE" >> env-artifact.sh
# Keeper Run Envs
echo "export CLUSTER=$CLUSTER" >> env-artifact.sh
#mango-simulation build repo ENVS
echo "export MANGO_SIMULATION_REPO=$MANGO_SIMULATION_REPO" >> env-artifact.sh
echo "export MANGO_SIMULATION_BRANCH=$MANGO_SIMULATION_BRANCH" >> env-artifact.sh
echo "export MANGO_SIMULATION_DIR=$MANGO_SIMULATION_DIR" >> env-artifact.sh
#mango-configuration build repo ENVS
# echo "export MANGO_CONFIGURE_REPO=$MANGO_CONFIGURE_REPO" >> env-artifact.sh
# echo "export MANGO_CONFIGURE_BRANCH=$MANGO_CONFIGURE_BRANCH" >> env-artifact.sh
# echo "export MANGO_CONFIGURE_DIR=$MANGO_CONFIGURE_DIR" >> env-artifact.sh
## CI program ENVS
echo "export GIT_TOKEN=$GIT_TOKEN" >> env-artifact.sh
echo "export GIT_REPO=$GIT_REPO" >> env-artifact.sh
echo "export NUM_CLIENT=$NUM_CLIENT" >> env-artifact.sh
echo "export AVAILABLE_ZONE=$AVAILABLE_ZONE" >> env-artifact.sh
echo "export SLACK_WEBHOOK=$SLACK_WEBHOOK" >> env-artifact.sh
echo "export KEEP_INSTANCES=$KEEP_INSTANCES" >> env-artifact.sh
## Metric Env
cat dos-metrics-env.sh >> env-artifact.sh
## artifact address
echo "export ENV_ARTIFACT=gs://buildkite-dos-agent/$BUILDKITE_PIPELINE_ID/$BUILDKITE_BUILD_ID/$BUILDKITE_JOB_ID/env-artifact.sh" >> env-artifact.sh
echo "export MANGO_SIMULATION_ARTIFACT=gs://buildkite-dos-agent/$BUILDKITE_PIPELINE_ID/$BUILDKITE_BUILD_ID/$BUILDKITE_JOB_ID/mango-simulation" >> env-artifact.sh

exit 0
