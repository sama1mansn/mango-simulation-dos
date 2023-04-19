#!/usr/bin/env bash
set -ex
# shellcheck source=/dev/null
source $HOME/.profile
# shellcheck source=/dev/null
source $HOME/env-artifact.sh
upload_log_folder() {
	gsutil cp -r $1 gs://mango_bencher-dos-log/

}
echo ----- stage: upload logs: make folder and move logs ------
cd $HOME
[[ -d "$HOME/$BUILDKITE_BUILD_ID/$HOSTNAME" ]] && ls -al "$HOME/$BUILDKITE_BUILD_ID/$HOSTNAME" || exit 1
upload_log_folder "$HOME/$BUILDKITE_BUILD_ID/$HOSTNAME"
echo "all logs are uploaded"
exit 0

