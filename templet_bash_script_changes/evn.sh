#!/bin/bash

# TODO suggest re-naming this to the actual init-server.sh script for consistency

# Lookup Conversion
# Following HOST Naming standards last 2 characters of server name are environmental assignment
# D = dev
# P = production
node_env_tmp=$(echo $HOSTZ | cut -d'-' -f3 | head -c 1)
case "$node_env_tmp" in
  D)
  node_env="dev"
  ;;
  P)
  node_env="prod"
  ;;
esac

# GridName for Request
node_appname=$(echo $HOSTZ | cut -d'-' -f2)
node_gridname="${node_appname,,}-$node_env"

value="$(curl http://localhost:8000/hooks/gridInfo)"

# Just set the global variable DEBUG_COOK=true to activate the code selection
if [ ! -z $DEBUG_COOK ]; then
  PS3='Please select your GRID NAME: '
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
  answer=$(echo ${answer//\"/})
else
  answer=$node_gridname
fi

# Returning grid information
# TODO: This should really be moved into the actual service so the service only returns this information for security reasons
echo $answer
IP="$(echo ${value} | jq '.[0].masterDNS')"

master_ip=$(echo ${IP//\"/})
echo $master_ip

TOKEN="$(echo ${value} | jq --arg ans $answer '.[0].grids[]|select(.name==$ans)|.token')"

grid_token=$(echo ${TOKEN//\"/})
echo $grid_token

# This won't work! this sub-shell doesn't have access to change the parents environmental variables
# Use SED and directly update the env.sh file or template.yml (whatever makes more sense)
export MASTER_IP=$master_ip
export GRID_TOKEN=$grid_token
