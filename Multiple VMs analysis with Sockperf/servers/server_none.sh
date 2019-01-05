#!/bin/sh
#This is the server
echo "********************** THIS IS THE SERVER FOR NONE MODE CASE  *************************"

# Get the ip address of the server
ipservernone=`hostname -I | awk '{print $1}'| cut -f2 -d:`
echo "IP address of the server is :" $ipservernone


#Install sockperf
# 1) None mode
':
apt-get -y update
apt-get install -y git autoconf automake libtool -y
git clone https://github.com/Mellanox/sockperf.git
apt-get -y install build-essential
cd sockperf/
./autogen.sh
./configure
make
make install
'

apt-get -y install parallel
parallel ::: "sockperf server --tcp -i $ipservernone -p 11110" "sockperf server -i $ipservernone -p 11111"
