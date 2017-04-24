#!/bin/bash
# Script to install the full Agora system.

here=$(pwd)
logFile=$(pwd)"/install_system.log"

echo -e "Installing Agora to your machine.  Please be patient as we install a lot of dependencies...\nIf there are any errors, please refer to $logFile" 2>&1


# Install dependencies
echo -e "Installing dependencies (expect this to take a long time)"
apt-get install -y make libcairo2-dev libpng12-dev libjpeg-dev libossp-uuid-dev  freerdp-x11 libssh2-1 libfreerdp-dev libvorbis-dev gcc libssh-dev libpulse-dev tomcat7 tomcat7-admin tomcat7-docs libpango1.0-dev libssh2-1-dev git python-tk >> $logFile 2>&1
echo -e "Wave 1 installed"
apt-get install -y libvncserver-dev >> $logFile 2>&1
echo -e "Wave 2 installed"
apt-get install -y xvfb x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic x11-apps x11vnc >> $logFile 2>&1
echo -e "Wave 3 installed"
apt-get install -y maven >> $logFile 2>&1
echo -e "Wave 4 installed"
apt-get install -y default-jdk >> $logFile 2>&1
echo -e "Wave 5 installed"
echo -e "Finished installing dependencies\n"


# Download and install guacamole.
echo -e "Download and install guacamole"
wget -O guacamole-server-0.9.9.tar.gz http://sourceforge.net/projects/guacamole/files/current/source/guacamole-server-0.9.9.tar.gz/download >> $logFile 2>&1
tar -xvzf guacamole-server-0.9.9.tar.gz >> $logFile 2>&1
cd guacamole-server-0.9.9 >> $logFile 2>&1
./configure --with-init-dir=/etc/init.d >> $logFile 2>&1
make && make install >> $logFile 2>&1
update-rc.d guacd defaults >> $logFile 2>&1
ldconfig >> $logFile 2>&1
mkdir /etc/guacamole >> $logFile 2>&1
cd /home/Agora >> $logFile 2>&1
rm -r $here/guacamole-server-0.9.9/ >> $logFile 2>&1
rm $here/guacamole-server-0.9.9.tar.gz >> $logFile 2>&1
echo -e "Finished installing guacamole\n"


# Clone Agora repo to /home folder.
echo -e "Get Agora from github"
cd /home >> $logFile 2>&1
git clone https://github.com/Calvin-CS/Agora >> $logFile 2>&1
echo -e "Finished configuring Agora\n"


# Copy over guacamole setting files.
echo -e "Configure guacamole settings"
cp -r Agora/settings-guac/* /etc/guacamole/ >> $logFile 2>&1
cd /etc/guacamole >> $logFile 2>&1
chmod 777 . >> $logFile 2>&1
echo -e "Finished configuring guacamole settings\n"


# Make a link to the properties file so that the guacaole server can read it.
echo -e "Set up tomcat7"
mkdir /usr/share/tomcat7/.guacamole >> $logFile 2>&1
#cp settings-guac/guacamole.properties /usr/share/tomcat7/.guacamole/ > $logFile 2>&1
ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat7/.guacamole/

# make a link to the webapps files to override tomcat's default page with the Agora page.
rm -r /var/lib/tomcat7/webapps >> $logFile 2>&1
ln -s /home/Agora/webapps /var/lib/tomcat7/ >> $logFile 2>&1
echo -e "Finished setting up tomcat7\n"


# Build the maven project then copy the resulting war file to the webapps directory.
echo -e "Build the maven project"
cd /home/Agora/guacamole-client/guacamole >> $logFile 2>&1
./buildeploy.sh >> $logFile 2>&1
echo -e "Finished building the maven project\n"


# Set up some permissions and create necessary folders and files
echo -e "Set up permissions and create necessary folders and files"
cd /home/Agora >> $logFile 2>&1
sudo chmod 666 pids
touch pids/recent.txt
sudo chmod 666 pids/recent.txt
sudo chmod 666 resources/current_ports.txt
mkdir /home/Agora/logs
sudo chmod 666 /home/Agora/logs
touch /home/Agora/logs/start_sh.log
sudo chmod 666 /home/Agora/logs/start_sh.log
echo -e "Finished setting up permissions\n"

# Install Docker
# Ask if the user wants Docker installed
echo -e "Optional Installations"
echo -e "Docker is a useful package manager that will help to manage supported language and library versions."
echo -e "This has only been tested for Ubuntu 16.04, but may work for other distributions"
read -p "Would you like to install Docker? Enter 'y' or 'n': "
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo -e "Installing Docker"
  echo -e "If anything fails here, please refer to Docker's documentation for help (https://docs.docker.com/engine/installation/)"
  sudo apt-get install apt-transport-https ca-certificates curl software-properties-common >> $logFile 2>&1
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >> $logFile 2>&1
  echo -e "Verify the fingerprint is '9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88'"
  sudo apt-key fingerprint 0EBFCD88
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >> $logFile 2>&1
  sudo apt-get update >> $logFile 2>&1
  sudo apt-get install docker-ce >> $logFile 2>&1
  echo -e "Test that docker was successfully installed"
  docker run hello-world
  sudo groupadd docker
  sudo usermod -aG docker tomcat7
  sudo systemctl enable docker
  echo -e "Finished installing Docker"
fi

# Start/Restart required services
echo -e "Restart guacd and tomcat7"
service guacd start >> $logFile 2>&1
service tomcat7 restart >> $logFile 2>&1
echo -e "Agora has been deployed, navigate to localhost:8080 (or <domain_name>:8080) to see the results"
echo -e "For documentation on use/customization, see the /home/Agora/readme folder."
