G#!/bin/bash

set -x

# USAGE
## a=5
##check_variable a
check_variable(){
  input=$1
  var=${!input}
  if [[ ! -z ${var} ]]
  then
    echo "exists $input : $var "
  else
    echo "$input cannot be empty"
    exit 2
  fi
}

check_response(){
  var=$1
  res="$(echo "$var" | jq .success)"

#  if [[ "${res,,}" -eq "false" ]]
#  if [[ "${res}" -eq "false" ]]
#if [[ ${res} -eq "truee" ]]
 
if $res
 then
    #exit 100
    echo "success"
  else
    exit 100
  fi
}

#INPUT FROM JENKINS
# User created in Matillion with permission enable for API
user=azure-user
password=azure-user
workEnv=Dev
repoName=Matillion_Test_1
github_url=https://github.com/jaya-bharath/${repoName}.git

#git clone in the current location
#cp ${repoName}/* .

rm -rf ${repoName}
git clone $github_url  #Authorization required

#prop file [GIT]
source ${repoName}/properties.sh

check_variable vm_url
check_variable group
check_variable project
check_variable toVersion
check_variable jobName
check_variable repoName

#if [[ "${deleteJob^^}" -eq "Y" ]
if [[ "$deleteJob" == [Yy] ]]
then

  check_variable scheduleName
# Delete schedule
  curl -u "${user}:${password}" -X POST ${vm_url}/rest/v1/group/name/${group}/project/name/${project}/schedule/name/${scheduleName}/delete

# Delete Job [cannot delete if the schedule is in place]
  curl -u "${user}:${password}" -X POST ${vm_url}/rest/v1/group/name/${group}/project/name/${project}/version/name/${toVersion}/job/name/${jobName}/delete
fi

#import job
# shellcheck disable=SC2154
importJob="$(curl -s -u "${user}:${password}" -X POST ${vm_url}/rest/v1/group/name/${group}/project/name/${project}/version/name/${toVersion}/job/import -H "content-type:application/json" --data @${repoName}/${jobName}.json)"

#check_response "$importJob"

#test environment availability
# testEnv="$(curl -s -u "${user}:${password}" -X POST ${vm_url}/rest/v1/group/name/${group}/project/name/${project}/environment/name/${workEnv}/test)"
#check_response "$testEnv"

#validate job
#curl -s -u "${user}:${password}" -X POST ${vm_url}/rest/v1/group/name/${group}/project/name/${project}/version/name/${toVersion}/job/name/${jobName}/validate?environmentName=${workEnv}

#schedule job
scheduleJob="$(curl -s -u "${user}:${password}" -X POST ${vm_url}/rest/v1/group/name/${group}/project/name/${project}/schedule/import -H "content-type:application/json" --data @${repoName}/schedule.json)"
#validate Schedule

check_response "$scheduleJob"
