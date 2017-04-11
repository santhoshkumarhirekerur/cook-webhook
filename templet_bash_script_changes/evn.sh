#!/bin/bash


PS3='Please select your GRID NAME: '
value="$(curl http://10.61.40.101:9000/hooks/gridInfo)"
options="$(echo ${value} | jq '.[0].grids[]| .name')"

oldIFS=$IFS
IFS=$'\n'
choices=( $options )
IFS=$oldIFS
PS3="Please enter your choice: "
select answer in "${choices[@]}"; do
  for item in "${choices[@]}"; do
    if [[ $item == $answer ]]; then
      break 2
    fi
  done
done
echo $answer

answer=$(echo ${answer//\"/})
IP="$(echo ${value} | jq '.[0].masterDNS')"

master_ip=$(echo ${IP//\"/})
echo $master_ip

TOKEN="$(echo ${value} | jq --arg ans $answer '.[0].grids[]|select(.name==$ans)|.token')"

grid_token=$(echo ${TOKEN//\"/})
echo $grid_token


export MASTER_IP=$master_ip
export GRID_TOKEN=$grid_token
