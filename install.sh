#!/bin/bash

# Exit on error
set -e

# Update package index
#sudo apt update -y
#sudo apt upgrade -y

# Install Java (OpenJDK 17)
echo "Installing Java..."
sudo apt install -y openjdk-17-jdk

# Verify Java installation
java -version

# Set JAVA_HOME
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /etc/profile
#source /etc/profile

echo "Java installed and configured."

# Install Maven
echo "Installing Maven..."
sudo apt install -y maven

# Verify Maven installation
mvn -version

echo "Maven installed."

# Install Tomcat
echo "Installing Tomcat..."
TOMCAT_VERSION=10.1.34
wget https://dlcdn.apache.org/tomcat/tomcat-10/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
sudo tar -xzf apache-tomcat-$TOMCAT_VERSION.tar.gz -C /opt
sudo mkdir -p /opt/tomcat
sudo mv  /opt/apache-tomcat-$TOMCAT_VERSION/* /opt/tomcat

# Set permissions for Tomcat
#sudo chmod +x /opt/tomcat/bin/*.sh

# Create Tomcat service
sudo bash -c 'cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME='$JAVA_HOME'
Environment=CATALINA_HOME=/opt/tomcat

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd and start Tomcat
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Verify Tomcat installation
if systemctl is-active --quiet tomcat; then
    echo "Tomcat installed and running."
else
    echo "Tomcat installation failed or service not running."
fi

# Clean up installation files
#rm -f apache-tomcat-$TOMCAT_VERSION.tar.gz

echo "Installation and configuration complete."
echo "Access Tomcat at http://<your-server-ip>:8080"

