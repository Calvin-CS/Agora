#!/bin/bash
#
# Agora
# Authors: Joel Stehouwer and Andrew Lang
#
# This kills all processes related to the specified running project
#
# This file is called by the KillServlet found in
# 'Agora/guacamole-client/guacamole/src/main/java/agora/KillServlet.java'
#################

logfile="/home/Agora/logs/kill_sh.log"

# Kill the process specified by command line argument
pid=$1
echo "kill.sh: Killing processes relating to ${pid}"

echo -e "Killing processed related to $pid" >> $logfile

while IFS='' read -r line
do
  echo -e $line >> $logfile
  kill $line
done < /home/Agora/pids/$pid.pid
python2 /home/Agora/scripts/clean_up_process_with_id.py $pid
rm /home/Agora/pids/$pid.pid
