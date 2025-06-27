#!/bin/bash

echo ""

servicePids=$(pidof Services.Host)

if [ -z $servicePids ]
then
  echo "Harmony Core service: NOT running"
else
  echo "Harmony Core service: $servicePids"
fi

workerPids=`ps aux | grep -E '[d]b[rs].*host\.dbr$' | awk '{print $2}'`

if [ -z workerPids ]
then
  echo "Traditional bridge workers: NONE"
else
  echo "Traditional bridge workers: $workerPids"
fi

echo ""
