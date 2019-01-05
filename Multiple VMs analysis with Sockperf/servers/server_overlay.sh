#!/bin/sh
#This is the server
echo "********************** THIS IS THE SERVER FOR OVERLAY MODE CASE  *************************"

# Get the ip address of the server
ipserver=`hostname -I | awk '{print $3}'| cut -f2 -d:`
echo "IP address of the server is :" $ipserver


docker swarm init
docker swarm init --advertise-addr=$ipserver
docker network create --driver=overlay --attachable my_overlay_net
docker run -it --name def_overlay_container_server --network my_overlay_net ubuntu:16.04

#Install sockperf inside the container

docker exec -i def_overlay_container_server bash <<'EOF'
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

parallel ::: "sockperf server --tcp -i $ipserver -p 44440" "sockperf server -i $ipserver -p 44441"

EOF
