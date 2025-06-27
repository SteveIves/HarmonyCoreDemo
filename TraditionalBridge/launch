#!/bin/bash
#
# Launch the traditional bridge host program on Linux (local or remote)
#
# Parameters:
#
# $1    Traditional bridge logging level (-1 to 6, default 2)
# $2    Remote debugger mode (NONE, TELNET or VS)
# $3    Remote debugger port 
# $4    Remote debugger delay
# $5    Startup script to run (NONE or script, currently not in use)
# $6    Stuck process detection seconds (<1 = disabled)

#------------------------------------------------------------------------------
# Verify that we have a Synergy environment

if [ -z $DBLDIR ]; then
  echo "ERROR: No DBL environment detected!"
  return 2> /dev/null; exit
fi

#------------------------------------------------------------------------------
# Put us in the TraditionalBridge directory

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR

#------------------------------------------------------------------------------
# Determine the environment name

if [ -e environment ]; then
  ENVIRONMENT=`cat environment`
  if [ -z "$ENVIRONMENT" ]; then
    echo "ERROR: Failed to determine environment name. Check file 'environment'"
    return 2> /dev/null; exit
  fi
else
  echo "ERROR: Unable to determine environment. Define the environment name in file 'environment'"
  return 2> /dev/null; exit
fi

#------------------------------------------------------------------------------
# If we have an executable setup script, run it

if [ -x startserver.$ENVIRONMENT.config ]; then
  source startserver.$ENVIRONMENT.config
fi

#------------------------------------------------------------------------------
# Set the logging level

if [ -z $1 ]; then
  export HARMONY_LOG_LEVEL=2
else
  export HARMONY_LOG_LEVEL=$1
fi

#------------------------------------------------------------------------------
# If specified, configure for remote debugging

# No remote debugger support
if [ -z $2 ] || [ "$2" == "NONE" ]; then
  LAUNCH_COMMAND="dbs host.dbr"
else
  # TELNET or VS debug support
  #Port number
  if [ -z $3 ]; then
    DEBUG_PORT=4444
  else
    DEBUG_PORT=$3
  fi
  #Connect window
  if [ -z $4 ]; then
    DEBUG_DELAY=30
  else
    DEBUG_DELAY=$4
  fi
fi

if [ "${2,,}" == "telnet" ]; then
  LAUNCH_COMMAND="dbr -rd $DEBUG_PORT:$DEBUG_DELAY host.dbr"
elif [ "${2,,}" == "vs" ]; then
  LAUNCH_COMMAND="dbr -dv -rd $DEBUG_PORT:$DEBUG_DELAY host.dbr"
fi

#------------------------------------------------------------------------------
# Enable open file checking everywhere except production

if [ "$ENVIRONMENT" != "Production" ]; then
  export CHECK_OPEN_CHANNELS=YES
fi

#------------------------------------------------------------------------------
# Enable stuck process detection

if [[ $6 =~ ^[0-9]+$ ]] && (( $6 > 0 )); then
  export STUCK_PROCESS_SECONDS=$6
else
  export STUCK_PROCESS_SECONDS=0
fi

#------------------------------------------------------------------------------
# Start the Traditional Bridge host program

if [[ -t 0 ]]; then
  stty -echo -onlcr
fi

$LAUNCH_COMMAND

if [[ -t 0 ]]; then
  stty echo onlcr
fi
