#!/bin/sh
#This is the server
echo "********************** THIS IS THE SERVER FOR BRIDGE MODE CASE  *************************"

#Create containers with bridge mode
docker run -it -d --name bridge_container_server_iperf ubuntu:16.04

#Install Iperf3 inside the container

docker exec -i bridge_container_server_iperf bash <<'EOF'
apt-get -y update
apt-get install iperf3 -y

apt-get -y install parallel

parallel ::: "iperf3 -s $(hostname -I) -p 22220" "iperf3 -s $(hostname -I) -p 22221"

EOF

