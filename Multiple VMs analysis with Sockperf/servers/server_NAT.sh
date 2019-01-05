#!/bin/sh
#This is the server
echo "********************** THIS IS THE SERVER FOR NAT MODE CASE  *************************"
# Get the ip address of the server
ipservernat=`hostname -I | awk '{print $1}'| cut -f2 -d:`
echo "IP address in NAT mode case of the server is :" $ipservernat

#Create containers with NAT mode
docker run -it -d --name NAT_container_server  -p 22220:22220 -p 22221:22221/udp ubuntu:16.04

#Install sockperf inside the container

docker exec -i NAT_container_server bash <<'EOF'
apt-get -y update
apt-get install -y git autoconf automake libtool -y
git clone https://github.com/Mellanox/sockperf.git
apt-get -y install build-essential
cd sockperf/
./autogen.sh
./configure
make
make install

apt-get -y install parallel
parallel ::: "sockperf server --tcp -i $ipservernat -p 22220" "sockperf server -i $ipservernat -p 22221"

EOF

