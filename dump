#!/bin/bash

# Check we are running as root

isroot=`id -u`
if [[ $isroot != 0 ]]
then
  echo -e "\nERROR: This script must be run as root.\n"
  return 2> /dev/null; exit
fi

# Check that dotnet-dump is installed

if [ ! -x /root/.dotnet/tools/dotnet-dump ]
then
  echo -e "\nERROR: The dotnet-dump utility was not found!\n"
  return 2> /dev/null; exit
fi

# Find the process ID of Services.Host

thepid=$(pidof Services.Host)
if [ -z $thepid ]
then
  echo -e "\nERROR: Services.Host is not running!\n"
  return 2> /dev/null; exit
fi

echo "Services.Host process found (pid $thepid)"

# Dump the process (this creates /tmp/coredump.<pid>)

echo "Creating coredump file"
./createdump $thepid

# Did it work?

if [[ ! $? -eq 0 ]]
then
  echo -e "\nERROR: The createdump command failed!\n"
  return 2> /dev/null; exit
fi

# Do we have a dump file?

if [ ! -e /tmp/coredump.$thepid ]
then
  echo -e "\nERROR: Dump file /tmp/coredump.$thepid not found!\n"
  return 2> /dev/null; exit
fi
  
# Analyze the dump file (interactive)

echo "Analyzing coresump file"
sudo /root/.dotnet/tools/dotnet-dump analyze /tmp/coredump.$thepid

else
  echo -e "\nERROR: No such process!\n"
  return 2> /dev/null; exit
fi

# Dump the process (this creates /tmp/coredump.<pid>)

./createdump $1

if [[ ! $? -eq 0 ]]
then
  echo -e "\nERROR: The createdump command failed!\n"
  return 2> /dev/null; exit
fi

if [ ! -e /tmp/coredump.$1 ]
then
  echo -e "\nERROR: Dump file /tmp/coredump.$1 not found!\n"
  return 2> /dev/null; exit
fi

# Analyze the dump file (interactive)

sudo /root/.dotnet/tools/dotnet-dump analyze /tmp/coredump.$1

