#!/usr/bin/env bash
# print-log.sh
# shellcheck source=/dev/null
set -x
source utils.sh
echo ---- stage: print log ----
if [[ "$PRINT_LOG" == "true" ]];then
    # only download start-dos-test(1).nohup file
    ret_download_log=$(download_file "gs://$ARTIFACT_BUCKET/$BUILDKITE_PIPELINE_ID/$BUILDKITE_BUILD_ID" start-dos-test1.nohup ./) || true
fi
if [[ -f  "start-dos-test1.nohup" ]];then
    cat start-dos-test1.nohup
else 
    echo "no start-dos-test1.nohup found"
fi
