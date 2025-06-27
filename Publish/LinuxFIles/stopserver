#!/bin/bash

# Make sure we are running as root

ISROOT=`id -u`
if [[ $ISROOT != 0 ]]; then
  echo "ERROR: root privilege required!"
  return 2> /dev/null; exit
fi

# Make sure we are in the same directory as the script

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR

VALID_ENVIRONMENTS="|LinuxDemo|"

# Get the environment name

if [ -e .environment ]; then
  ENVIRONMENT=`cat .environment`
  if [ -z "$ENVIRONMENT" ]; then
    echo "ERROR: Failed to determine environment name. Check hidden file '.environment'"
    return 2> /dev/null; exit
  fi
  if [[ ! "$VALID_ENVIRONMENTS" == *"|$ENVIRONMENT|"* ]]; then
    echo "ERROR: Invalid environment name $ENVIRONMENT in hidden file '.environment'"
    return 2> /dev/null; exit
  fi
else
  echo "ERROR: Unable to determine environment. Define the environment name in hidden file '.environment'"
  echo "Valid environments: $VALID_ENVIRONMENTS"
  echo "Do not include the | characters"
  return 2> /dev/null; exit
fi

# Execute the configuration file

if [ -e startserver.$ENVIRONMENT.config ]; then
  dos2unix -q startserver.$ENVIRONMENT.config
  chmod +x startserver.$ENVIRONMENT.config
  source startserver.$ENVIRONMENT.config
fi

# Define the binary name for this instance of the service

export SERVER_BINARY=Services.Host.$ENVIRONMENT

# Check that the service is running

SERVER_PID=`pidof $SERVER_BINARY`
if [ -z "$SERVER_PID" ]; then
  echo "$SERVER_BINARY is not running!"
  return 2> /dev/null; exit
fi

# Try to stop the service with a SIGTERM

echo "Sending SIGTERM to service $SERVER_BINARY"
kill -15 $SERVER_PID
sleep 1

# Check if the SIGTERM worked

SERVER_PID=`pidof $SERVER_BINARY`
if [ -z "$SERVER_PID"]; then
  echo "Service stopped via SIGTERM"
  return 2> /dev/null; exit
fi

# Try to stop the service with a SIGABRT

echo "Sending SIGABRT to service $SERVER_BINARY"
kill -6 $SERVER_PID
sleep 1

# Check if the SIGABRT worked

SERVER_PID=`pidof $SERVER_BINARY`
if [ -z "$SERVER_PID"]; then
  echo "Service stopped via SIGABRT"
  return 2> /dev/null; exit
fi

# Kill the service with a SIGKILL

echo "Service did not stop; sending SIGKILL!"
kill -9 $SERVER_PID
sleep 1

# Check if the kill -9 worked

SERVER_PID=`pidof $SERVER_BINARY`
if [ -z "$SERVER_PID" ]; then
  echo "Service killed via SIGKILL"
  return 2> /dev/null; exit
fi

# It's still running; not much we can do!
echo "ERROR: Failed to stop service!"
