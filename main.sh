
#!/usr/bin/env bash
set -ex
## Directory settings
dos_program_dir=$(pwd)
echo ----- stage: show envs upload as an artifcat ---- 
source env-artifact.sh
echo ----- stage: prepare files to run the mango_bencher in the clients --- 
# setup Envs here so that generate-exec-files.sh can be used individually
# accounts=( "$ACCOUNTS" )
#Generate first dos-test machine
# source generate-exec-dos-test.sh
# acct_num=1
# for acct in "${accounts[@]}"
# do
#     ACCOUNT_FILE=$acct
#     [[ acct_num -ne 1 ]]&& RUN_KEEPER="false"
#     echo RUN_KEEPER=$RUN_KEEPER
#     gen_dos_test $acct_num
#     let acct_num=$acct_num+1
# done

echo ----- stage: machines and build and upload mango-simulation ---
cd "$dos_program_dir"
# shellcheck source=/dev/null
source create-instance.sh
create_machines "$NUM_CLIENT"
echo ----- stage: build dependency mango_bencher configure_mango for machine------
client_num=1
arg2="$BUILDKITE_PIPELINE_ID/$BUILDKITE_BUILD_ID/$BUILDKITE_JOB_ID"
arg3="$ENV_ARTIFACT_FILE"
for sship in "${instance_ip[@]}"
do
    [[ $client_num -eq 1 ]] && arg1="true" || arg1="false"
    [[ $BUILD_MANGO_SIMULATOR != "true" ]] && arg1="false" # override the arg1 base on input from Steps
    # run start-build-dependency.sh which in agent machine
    ret_build_dependency=$(ssh -i id_ed25519_dos_test -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" sol@"$sship" 'bash -s' < start-build-dependency.sh "$arg1" "$arg2" "$arg3")
    (( client_num++ )) || true
done

echo ----- stage: run dos test ---
accounts=( "$ACCOUNTS" )
client_num=1
for sship in "${instance_ip[@]}"
do
    (( idx=$client_num -1 )) || true
    [[ $client_num -eq 1 ]] && arg2=true || arg2=false
    [[ $RUN_KEEPER != "true" ]] && arg2=false # override the arg2 base on input from Steps
    acct=accounts[$idx]
    echo acct=$acct
    # run start-dos-test.sh which in client machine
    ret_run_dos=$(ssh -i id_ed25519_dos_test -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" sol@$sship "nohup /home/sol/start-dos-test.sh $acct $arg2 1> start-dos-test.nohup 2> start-dos-test.nohup &")
    (( client_num++ )) || true
    [[ $client_num -gt ${#accounts[@]} ]] && client_num=1    
done
# # Get Time Start
start_time=$(date -u +%s)
start_time_adjust=$(get_time_after $start_time 5)
echo ----- stage: wait for bencher concurrently ------
sleep $DURATION
echo ----- stage: check finish of process ---
sleep 5
for sship in "${instance_ip[@]}"
do
    ret_pid=$(ssh -i id_ed25519_dos_test -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" sol@$sship 'pgrep --full "bash /home/sol/start-dos-test.sh*"' > pid.txt)
    pid=$(cat pid.txt)
    [[ $pid == "" ]] && echo "$sship has finished run mango-simulation" || echo "pid=$pid"
    while [ "$pid" != "" ]
    do
        sleep 3
        ret_pid=$(ssh -i id_ed25519_dos_test -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" sol@$sship 'pgrep --full "bash /home/sol/start-dos-test.sh*"' > pid.txt) || true
        [[ $pid == "" ]] && echo "$sship has finished run mango-simulation" || echo "pid=$pid"
    done
done

echo ----- stage: upload logs ------
for sship in "${instance_ip[@]}"
do
    ret_pre_build=$(ssh -i id_ed25519_dos_test -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" sol@$sship /home/sol/start-upload-logs.sh)
done


# ### Get Time Stop
# stop_time=$(date -u +%s)
# stop_time_adjust=$(get_time_before $stop_time 5)
# echo ----- stage: DOS report ------
# get_testnet_ver
# ## PASS ENV
# [[ $SLACK_WEBHOOK ]]&&echo "SLACK_WEBHOOK=$SLACK_WEBHOOK" >> dos-report-env.sh
# [[ $DISCORD_WEBHOOK ]]&&echo "DISCORD_WEBHOOK=$DISCORD_WEBHOOK" >> dos-report-env.sh
# [[ $DISCORD_AVATAR_URL ]]&&echo "DISCORD_AVATAR_URL=$DISCORD_AVATAR_URL" >> dos-report-env.sh
# echo "START_TIME=${start_time}" >> dos-report-env.sh
# echo "START_TIME2=${start_time_adjust}" >> dos-report-env.sh
# echo "STOP_TIME=${stop_time}" >> dos-report-env.sh
# echo "STOP_TIME2=${stop_time_adjust}" >> dos-report-env.sh
# echo "DURATION=$DURATION" >> dos-report-env.sh                 
# echo "QOUTES_PER_SECOND=$QOUTES_PER_SECOND" >> dos-report-env.sh
# echo "NUM_CLIENT=$NUM_CLIENT" >> dos-report-env.sh
# echo "CLUSTER_VERSION=$testnet_ver" >> dos-report-env.sh

# for n in "${instance_name[@]}"
# do
#     printf instances "%s %s" $instances $n
# done
# echo "INSTANCES=$instances" >> dos-report-env.sh

# ret_dos_report=$(exec ./dos-report.sh)
# echo $ret_dos_report

# echo ----- stage: printout run log ------
# if [[ "$PRINT_LOG" == "true" ]];then
# 	ret_log=$(ssh -i id_ed25519_dos_test -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" sol@${instance_ip[0]} 'cat /home/sol/start-dos-test.nohup')
# fi
# echo ----- stage: upload logs ------
# sleep 1200 #delay for log to be ready
# source generate-exec-upload-logs.sh
# for sship in "${instance_ip[@]}"
# do
#     ret_pre_build=$(ssh -i id_ed25519_dos_test -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" sol@$sship 'bash -s' < exec-start-upload-logs.sh)
# done

# sleep 10
# if [[ "$KEEP_INSTANCES" != "true" ]];then
#     echo ----- stage: delete instances ------
#     delete_machines
# fi

exit 0

# echo ----- stage: printout run log ------
# if [[ "$PRINT_LOG" == "true" ]];then
# 	ret_log=$(ssh -i id_ed25519_dos_test -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" sol@${instance_ip[0]} 'cat /home/sol/start-dos-test.nohup')
# fi
