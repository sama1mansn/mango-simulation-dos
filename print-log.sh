#!/usr/bin/env bash
# print-log.sh
# shellcheck source=/dev/null
set -x
source utils.sh
mango_simulation_artifact_bucket="$ARTIFACT_BUCKET/$BUILDKITE_PIPELINE_ID/$BUILDKITE_BUILD_ID/$BUILDKITE_JOB_ID"
echo ---- stage: print log ----
if [[ "$PRINT_LOG" == "true" ]];then
    download_file "gs://$mango_simulation_artifact_bucket" start-dos-test.nohup ./
fi
if [[ -f  "start-dos-test.nohup" ]];then
    cat start-dos-test.nohup
else 
    echo "no start-dos-test.nohup found"
fi
