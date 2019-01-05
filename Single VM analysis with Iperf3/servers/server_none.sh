#!/bin/sh
#This is the server
echo "********************** THIS IS THE SERVER FOR NONE MODE CASE  *************************"

# Get the ip address of the server
ipservernone=`hostname -I | awk '{print $1}'| cut -f2 -d:`
echo "IP address of the server is :" $ipservernone


#Install Iperf3
# 1) None mode
sudo apt-get -y update
sudo apt-get install iperf3 -y

apt-get -y install parallel
parallel ::: "iperf3 -s $ipservernone -p 11110" "iperf3 -s $ipservernone -p 11111"
