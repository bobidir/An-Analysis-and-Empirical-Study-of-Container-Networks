#!/bin/sh
#This is the server
echo "********************** THIS IS THE SERVER  *************************"
#Install docker 
:'
sudo apt-get -y update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
sudo groupadd docker
sudo gpasswd -a $USER docker
'

sudo apt-get -y install parallel
parallel ::: "cd servers && ./server_none.sh" "cd servers && ./server_bridge.sh" "cd servers && ./server_host.sh"
