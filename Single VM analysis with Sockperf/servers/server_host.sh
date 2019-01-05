#!/bin/sh
#This is the server
echo "********************** THIS IS THE SERVER FOR HOST MODE CASE  *************************"

# Get the ip address of the server
ipserver=`hostname -I | awk '{print $1}'| cut -f2 -d:`
echo "IP address of the server is :" $ipserver

#Create containers with bridge mode
docker run -it -d --name host_container_server --network host ubuntu:16.04


#Install sockperf inside the container

docker exec -i host_container_server bash <<'EOF'
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

parallel ::: "sockperf server --tcp -i $(hostname -I | awk '{print $3}'| cut -f2 -d:) -p 33330" "sockperf server -i $(hostname -I | awk '{print $3}'| cut -f2 -d:) -p 33331"

EOF

