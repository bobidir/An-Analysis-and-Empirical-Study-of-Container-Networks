#!/bin/sh
#This is the server
echo "********************** THIS IS THE SERVER FOR BRIDGE MODE CASE  *************************"

#Create containers with bridge mode
docker run -it -d --name bridge_container_server ubuntu:16.04

#Install sockperf inside the container

docker exec -i bridge_container_server bash <<'EOF'
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
parallel ::: "sockperf server --tcp -i $(hostname -I) -p 22220" "sockperf server -i $(hostname -I) -p 22221"

EOF

