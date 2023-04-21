#!/usr/bin/env bash
set -ex
# shellcheck source=/dev/null
source $HOME/.profile
# shellcheck source=/dev/null
source $HOME/env-artifact.sh

upload_log_folder() {
	gsutil cp -r $1 gs://mango_bencher-dos-log/$BUILDKITE_BUILD_NUMBER/
}

echo ----- stage: upload logs: make folder and move logs ------
cd $HOME
[[ -d "$HOME/$HOSTNAME" ]] && ls -al "$HOME/$HOSTNAME" || exit 1
upload_log_folder "$HOME/$HOSTNAME"
if [[ -f  "$HOME/start-dos-test.nohup" ]];then
	gsutil cp "$HOME/start-dos-test.nohup" "gs://$MANGO_SIMULATION_ARTIFACT_BUCKET/start-dos-test.nohup"
fi
echo "all logs are uploaded"
exit 0

