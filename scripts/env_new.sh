#!/bin/bash
# Bash Menu Script Example

PS3='Please select your GRID NAME: '
value="$(cat /root/grid-routes.json)"
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

IP=$(echo ${IP//\"/})
echo $IP

TOKEN="$(echo ${value} | jq --arg ans $answer '.[0].grids[]|select(.name==$ans)|.token')"

TOKEN=$(echo ${TOKEN//\"/})
echo $TOKEN
