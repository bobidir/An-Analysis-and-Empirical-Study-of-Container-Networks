#!/bin/sh
#This is the server
echo "********************** THIS IS THE SERVER  *************************"
#Install docker 

sudo apt-get -y update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo systemctl restart docker

sudo apt-get -y install parallel
parallel ::: "cd servers && ./server_none.sh" "cd servers && ./server_bridge.sh" "cd servers && ./server_host.sh"
