#!/bin/sh
#This is the server
echo "********************** THIS IS THE SERVER FOR HOST MODE CASE  *************************"

# Get the ip address of the server
ipserver=`hostname -I | awk '{print $1}'| cut -f2 -d:`
echo "IP address of the server is :" $ipserver

#Create containers with bridge mode
docker run -it -d --name host_container_server_iperf --network host ubuntu:16.04


#Install Iperf3 inside the container

docker exec -i host_container_server_iperf bash <<'EOF'
apt-get -y update
apt-get install iperf3 -y

apt-get -y install parallel

parallel ::: "iperf3 -s $(hostname -I | awk '{print $1}'| cut -f2 -d:) -p 33330" "iperf3 -s $(hostname -I | awk '{print $1}'| cut -f2 -d:) -p 33331"

EOF

