#!/bin/bash
#
# Agora
# Authors: Drew Campo and Corwin Webster
# Expanded by: Joel Stehouwer and Andrew Lang
#
# This starts a new project on a new display
#
# This file is called by the AgoraServlet found in
# 'Agora/guacamole-client/guacamole/src/main/java/agora/AgoraServlet.java'
############

# Log file that this script writes to
logfile="/home/Agora/logs/start_sh.log"
echo -e "Start begin" >> $logfile

############
# Find the next available port from port.txt, then increment port number
# TODO lock the file first
python2 /home/Agora/scripts/get_next_port.py
nextDisplay=$?
echo -e "$nextDisplay" >> $logfile
if [ "$nextDisplay" -eq "0" ]
then
  echo -e "No available displays" >> $logfile
  echo 0 > /home/Agora/pids/recent.txt
  exit 1
fi
echo -e "What is the port? $nextDisplay " >> $logfile
# TODO unlock the file
nextPort=$((nextDisplay+5900))
echo "Read $nextPort from file"
echo "Display will be $nextDisplay"
echo -e "Next display is $nextDisplay" >> $logfile

############
# Grab the program info dynamically from the command line. 
directory=$1
progName=$2
langVersion=$3
echo "Language is $langVersion"
echo -e "Program Name: $progName, and Language Version $langVersion" >> $logfile

############
# Start the display, Xvfb, python program, and x11vnc
export DISPLAY=:$nextDisplay
echo "AGORA:Display $nextDisplay set..."

/usr/bin/Xvfb :$nextDisplay -screen 0 1366x766x24 &
# Save the pid this xvfb is started on, keep a file for the most recent one
thisPid=$!
uniqueId=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
touch /home/Agora/pids/${uniqueId}.pid
echo $uniqueId > /home/Agora/pids/recent.txt
echo "AGORA:Xvfb starting on $nextDisplay ..."
echo -e "Agora process for $progName on pid $thisPid with unique identifier $uniqueId" >> $logfile
echo -e "Agora:Xvfb starting on $nextDisplay" >> $logfile

cd $directory
echo -e "CD'd to $directory" >> $logfile

# Handle different languages
# In order to add a new language to Agora, create an if block similar to those shown below
# The if block should have this format
#   if ["$langVersion" = "<lang>" ]
#   then
#     *Start the program*
#     progPid=$!
#     *Any desired logging*
#   fi
if [ "$langVersion" = "p2" ]
then
  #python2 /home/Agora/python/$progName &
  python2 $progName &
  progPid=$!
  echo "python 2"
  echo -e "$progName python 2 running" >> $logfile
fi
if [ "$langVersion" = "p3" ]
then
  #python3 /home/Agora/python/$progName &
  python3 $progName &
  progPid=$!
  echo "python 3"
  echo -e "$progName python 3 running" >> $logfile
fi

# Handle java console or gui programs
if [ "$langVersion" = "jc" ]
then
  xterm -fg white -bg black -e "bash -c \"clear; java $progName; read -n 1\"" &
  progPid=$!
  echo "java console program"
  echo -e "$progName java console running" >> $logfile
fi
if [ "$langVersion" = "jg" ]
then
  java $progName &
  progPid=$!
  echo "java gui program"
  echo -e "$progName java gui running" >> $logfile
fi
# Handle jar files
if [ "$langVersion" = "jar" ]
then
  xterm -fg white -bg black -e "bash -c \"clear; java -jar $progName; read -n 1\"" &
  progPid=$!
  echo "java compiled jar"
  echo -e "$progName java jar running" >> $logfile
fi

# Handle c++ console program
if [ "$langVersion" = "cpp" ]
then
  xterm -fg white -bg black -e "bash -c \"./$progName; read -n 1\"" &
  progPid=$!
  echo "c++ console program"
  echo -e "$progName c++ console running" >> $logfile
fi

if [ "$langVersion" = "cs" ]
then
  xterm -fg white -bg black -e "bash -c \"mono $progName; read -n 1\"" &
  progPid=$!
  echo "C# console program"
  echo -e "$progName C# console running" >> $logFile
fi 

if [ "$langVersion" = "docker" ]
then
  xterm -fg white -bg black -e "bash -c \"docker run -it -e DISPLAY=unix:$nextDisplay -v /tmp/.X11-unix:/tmp/.X11-unix $progName; read -n 1\"" &
  progPid=$!
  echo "Docker Container"
  echo -e "$progName Docker running" >> $logFile
fi 

cd -

echo "AGORA:starting $langVersion program $progName ..."

x11vnc -display :$nextDisplay -forever -shared -rfbport $nextPort &
x11Pid=$!
echo "AGORA:x11vnc server starting on port $nextPort ..."
echo -e "Agora:x11vnc server starting on $nextPort" >> $logfile

############
# Update noauth config file with new port. Remove the last line of the file,
# then add the new config, then add the final closing tag again.
noauthfile="/etc/guacamole/noauth-config.xml"
sed '$ d' $noauthfile > /etc/guacamole/temp.xml
mv /etc/guacamole/temp.xml $noauthfile
echo "    <config name='Agora Project Showcase -${uniqueId}-' protocol='vnc'>" >> $noauthfile
echo '        <param name="hostname" value="localhost" />' >> $noauthfile
echo "        <param name='port' value='$nextPort' />" >> $noauthfile
echo '    </config>' >> $noauthfile
echo '</configs>' >> $noauthfile
chmod 777 $noauthfile

echo -e "Start_sh end\n\n" >> $logfile

# Write the pids and port to the correct pid file in /home/Agora/pids
echo -e $thisPid > /home/Agora/pids/${uniqueId}.pid
echo -e $x11Pid >> /home/Agora/pids/${uniqueId}.pid
echo -e $progPid >> /home/Agora/pids/${uniqueId}.pid
