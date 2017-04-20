#!/bin/bash
# Script to build the maven project then copy the resulting war file to the webapps directory.

cd /home/Agora/guacamole-client/guacamole
mvn package
cd target

# Now copy the war file with an appropriate name to the tomcat webapps folder
mv agora-1.war agora.war
cp agora.war /home/Agora/webapps

# Delete the renamed war file so we don't have problems building next time
rm -r agora.war
echo "agora app deployed"

# Restart required services
service guacd restart
service tomcat7 restart
echo "Agora should be ready"
echo "If any services failed to restart, try 'sudo service guacd restart' and 'sudo service tomcat7 restart'"
