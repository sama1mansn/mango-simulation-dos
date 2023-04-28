# mango-simulation-dos
    Purpose is to use mango-simulation to do DOS test in Testnet
## Files
+ main.sh : main procedure
+ prepare-envs.sh: save envs from buildkite steps and buildkite envs to env-artifact.sh file. This enable share env between clients.
+ create-instatnce.sh
    - to create google cloud machines
+ start-build-dependency.sh : script to run in remote client to build dependencies
+ start-dos-test.sh : script to run in remore client to run mango_bencher dos test
+ start-upload-logs.sh : script to upload logs to google cloud bucket
+ dos-report: generates dos report from influxdb
+ discord.sh/slack.sh: send the dos report to slack or discord
+ print-log: print log of remote clients




