#!/usr/bin/env bash
# shellcheck source=/dev/null
source utils.sh
source env-artifact.sh
echo ---- stage: print log ----
if [[ "$PRINT_LOG" == "true" ]];then
    download_file "gs://$MANGO_SIMULATION_ARTIFACT_BUCKET" start-dos-test.nohup ./
fi
if [[ -f  "start-dos-test.nohup" ]];then
    cat start-dos-test.nohup
fi
