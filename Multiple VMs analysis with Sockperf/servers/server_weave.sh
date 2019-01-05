#!/bin/sh
#This is the server
echo "********************** THIS IS THE SERVER FOR WEAVE MODE CASE  *************************"

# Get the ip address of the server
ipserver=`hostname -I | awk '{print $3}'| cut -f2 -d:`
echo "IP address of the server is :" $ipserver

#Install Weave on the server 
sudo wget -O /usr/local/bin/weave \
        https://github.com/weaveworks/weave/releases/download/latest_release/weave
sudo chmod a+x /usr/local/bin/weave

#Launch weave containers
weave launch

#Create container on the server and then attach it the weave

docker run -it -d --name weave_container_server ubuntu:16.04
sudo weave attach weave_container_server

#Install sockperf inside the container

docker exec -i weave_container_server bash <<'EOF'
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

parallel ::: "sockperf server --tcp -i $ipserver -p 55550" "sockperf server -i $ipserver -p 55551"

EOF
