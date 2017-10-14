#!/usr/bin/env bash

rgname=$1
loc=$2
if [ "$2" != "" ]; then
    loc="koreacentral"
fi

az group create –n $rgname –l $loc

az group deployment create –n vmmsdeployment –g $rgname –-template-file azuredeploy.json \
  –-parameters @azuredeploy.parameter.json
