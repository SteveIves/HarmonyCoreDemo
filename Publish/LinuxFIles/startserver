#!/bin/bash

VALID_ENVIRONMENTS="|LinuxDemo|"

# Make sure we are in the same directory as the script

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR

# Get the environment name

if [ -e environment ]; then
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

# Make sure scripts are unix format and executable

SCRIPTS="check dump launch appsettings.*.json startserver.*.config stopserver"
dos2unix -q $SCRIPTS
chmod +x $SCRIPTS

# Execute the configuration file

if [ -e startserver.$ENVIRONMENT.config ]; then
  dos2unix -q startserver.$ENVIRONMENT.config
  chmod +x startserver.$ENVIRONMENT.config
  source startserver.$ENVIRONMENT.config
fi

# Define the binary name for this instance of the service

export SERVER_BINARY=Services.Host.$ENVIRONMENT

# Provide a custom binary if necessary so we can tell the difference between multiple services running on the same system

if [ ! -e $SERVER_BINARY ]; then cp Services.Host $SERVER_BINARY; fi
if [ ! -e $SERVER_BINARY.pfx ]; then cp Services.Host.pfx $SERVER_BINARY.pfx; fi

# Configure the ASP.NET environment

export ASPNETCORE_ENVIRONMENT=$ENVIRONMENT
export ASPNETCORE_URLS="https://*:$ASPNETCORE_HTTPS_PORT;http://*:$ASPNETCORE_HTTP_PORT"
export ASPNETCORE_Kestrel__Certificates__Default__Path=$SERVER_BINARY.pfx
export ASPNETCORE_Kestrel__Certificates__Default__Password="p@ssw0rd"

# Configure .NET crash dump generation

#export COMPlus_DbgEnableMiniDump=1
#export COMPlus_DbgMiniDumpType=4
#export COMPlus_EnableCrashReport=1


# Check the service is not already running

if pgrep -x "$SERVER_BINARY" > /dev/null
then
  echo "$SERVER_BINARY is already running!"
  return 2> /dev/null; exit
fi

# Start the service

chmod +x $SERVER_BINARY

if [[ ${1,,} == "attach" ]]; then
  #Run the service in the current process
  $SERVER_BINARY
  stty echo

elif [[ ${1,,} == "detach" ]]; then
  #Run the service in a detached process
  TIMESTAMP=`date "+%Y-%m-%d-%H-%M-%S"`
  SERVER_LOG_FILE=$SERVER_BINARY-$TIMESTAMP.log
  nohup setsid $SERVER_BINARY < /dev/null > $SERVER_LOG_FILE 2>&1 &
  echo Server was started as a deatched process. Log file is $SERVER_LOG_FILE

else
  echo -e "\nUsage: startserver attach|detach\n"
  return 2> /dev/null; exit
fi

# -----------------------------------------------------------------------------
# Optional CPU core locking
#
# Enabling this feature will restrict the main Harmony Core process (usually 
# Services.Host) to only running on a subset of the available CPU cores.
#
# To enable this feature create a hidden JSON configuration file named
# .CpuCoreLock.json in the same directory as this script and configure the
# content of the file similar to this:
#
# {
#   "EnableCoreLock": true,
#   "StartCore": 1,
#   "EndCore": 5
# }
#
# Ensure that EndCore is less than or equal to the total number of available
# cpu cores (you can find that with the nproc utility), and that StartCore
# is greater than 0 and less than EndCore.
# -----------------------------------------------------------------------------

# Do we have a configuration file for CPU core locking?

json_file=.CpuCoreLock.json

if [[ ! -e $json_file ]]; then
  # No, we're all done
  return 2> /dev/null; exit
fi

# Make sure we have jq (command line JSON parser)

if ! command -v jq &> /dev/null; then
  echo "ERROR: Can't configure CPU core locking because jq is not installed!"
  return 2> /dev/null; exit
fi

# Make sure we have taskset command

if ! command -v taskset &> /dev/null; then
  echo "ERROR: Can't configure CPU core locking because taskset is not installed!"
  return 2> /dev/null; exit
fi

# Determine if the server process is running, and get its pid

pid=$(pgrep -x "$SERVER_BINARY")

if ! [[ -n "$pid" ]]; then
  echo "ERROR: Process $SERVER_BINARY is not running"
  return 2> /dev/null; exit
fi

# Get the number of available CPU cores

if command -v nproc &> /dev/null; then
  max_cores=$(nproc)
elif [[ "$OSTYPE" == "darwin"* ]]; then
  max_cores=$(sysctl -n hw.ncpu)
else
  max_cores=$(grep -c ^processor /proc/cpuinfo)
fi

# Parse the configuration file

enabled=$(jq -r '.EnableCoreLock' "$json_file")
start_core=$(jq -r '.StartCore' "$json_file")
end_core=$(jq -r '.EndCore' "$json_file")

ok=true

# Validate EndCore is a positive integer and less than or equal to the number of CPU cores

if ! [[ "$end_core" =~ ^[1-9][0-9]*$ ]] || [ "$end_core" -gt "$max_cores" ]; then
  echo "ERROR: EndCore must be a positive integer less than or equal to $max_cores"
  ok = false
fi

# Validate StartCore is a positive integer and less than end_core

if ! [[ "$start_core" =~ ^[1-9][0-9]*$ ]] || [ "$start_core" -ge "$end_core" ]; then
  echo "ERROR: StartCore must be a positive integer less than EndCore"
  ok = false
fi

#Validate that Enabled is true or false

if [[ "$enabled" != "true" && "$enabled" != "false" ]]; then
  echo "ERROR: Enabled must be true or false"
  ok = false
fi

# Validate that both ok and enabled contain "true"

if [[ "$ok" == "true" && "$enabled" == "true" ]]; then
  # Limit the process to the specified CPU cores
  taskset -pc $start_core-$end_core $pid
  echo "Process $SERVER_BINARY has been restructed to CPU cores $start_core to $end_core"
fi

# End of CPU core locking
# -----------------------------------------------------------------------------
