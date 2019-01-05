#!/bin/sh
#This the client
echo "********************** THIS IS THE CLIENT  *************************"
#Install docker **************************************************
:'
sudo apt-get -y update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo systemctl restart docker

'
#Create containers with different modes
# 1) Bridge mode
docker run -it -d --name bridge_container_client ubuntu:16.04
# 2) Host mode
docker run -it -d --name host_container_client --network host ubuntu:16.04

# Get the ip address of the server
ipservernone=`hostname -I | awk '{print $1}'| cut -f2 -d:`
echo "IP address in NONE mode case of the server is :" $ipservernone


ipserverhost=`hostname -I | awk '{print $1}'| cut -f2 -d:`
echo "IP address in HOST mode case of the server is :" $ipserverhost

# install sockperf inside the containers ****************************************

# 1) Bridge mode

docker exec -i bridge_container_client bash <<EOF
apt-get -y update
apt -y install git autoconf automake libtool -y
git clone https://github.com/Mellanox/sockperf.git
apt-get -y install build-essential
cd sockperf/
./autogen.sh
./configure
make
make install
EOF

# 2) Host mode
docker exec -i host_container_client bash <<EOF
apt-get -y update
apt -y install git autoconf automake libtool -y
git clone https://github.com/Mellanox/sockperf.git
apt-get -y install build-essential
cd sockperf/
./autogen.sh
./configure
make
make install
EOF



# 30 tests for NONE mode with sockperf and put the results on excel file *********************************************************************************
echo 'NONE MODE TEST START*******************************************************************'
echo 'Mode' ',' 'Throughput TCP MBps' ',' 'Throughput UDP MBps '> statistiques/Node_Mode_Results.xls
for i in `seq 1 30`
do
# Throughput TCP and UDP
echo 'None mode' ',' `(sockperf throughput --tcp --msg-size=1024 -i $ipservernone -p 11110 -t 10 | grep 'BandWidth is ' | cut -d ' ' -f 5)` ',' `(sockperf throughput  --msg-size=1024 -i $ipservernone -p 11111 -t 10 | grep 'BandWidth is ' | cut -d ' ' -f 5)` >> statistiques/Node_Mode_Results.xls
done
# Calculate the average
echo 'Average' ',' `cat statistiques/Node_Mode_Results.xls | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` ',' `cat statistiques/Node_Mode_Results.xls | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'`>> statistiques/Node_Mode_Results.xls

# 30 tests for BRIDGE mode with sockperf and put the results on excel file *********************************************************************************
echo 'BRIDGE MODE TEST START *****************************************************************'

bridgeip=" $(docker exec -it bridge_container_server bash -c 'IP=$(hostname -i); echo $IP')"
echo "IP address in BRIDGE mode case ofthe server is :" $bridgeip

echo 'Mode' ',' 'Throughput TCP MBps' ',' 'Throughput UDP MBps '> statistiques/Bridge_Mode_Results.xls
for i in `seq 1 30`
do
# Throughput TCP and UDP
docker exec -i bridge_container_client /bin/bash << EOF >> statistiques/Bridge_Mode_Results.xls
echo 'Bridge mode' ',' `(sockperf throughput --tcp --msg-size=1024 -i $bridgeip -p 22220 -t 10 | grep 'BandWidth is ' | cut -d ' ' -f 5)` ',' `(sockperf throughput --msg-size=1024 -i $bridgeip -p 22221 -t 10 | grep 'BandWidth is ' | cut -d ' ' -f 5)`
exit
EOF
done
# Calculate the average
echo 'Average' ',' `cat statistiques/Bridge_Mode_Results.xls | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` ',' `cat statistiques/Bridge_Mode_Results.xls | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'`>> statistiques/Bridge_Mode_Results.xls


# 30 tests for HOST mode with sockperf and put the results on excel file *************************************************************************************

echo 'HOST MODE TEST START *****************************************************************'
echo 'Mode' ',' 'Throughput TCP MBps' ',' 'Throughput UDP MBps '> statistiques/Host_Mode_Results.xls
for i in `seq 1 30`
do
# Throughput TCP and UDP
docker exec -i host_container_client /bin/bash << EOF >> statistiques/Host_Mode_Results.xls
echo 'Host mode' ',' `(sockperf throughput --tcp --msg-size=1024 -i $ipserverhost -p 33330 -t 10 | grep 'BandWidth is ' | cut -d ' ' -f 5)` ',' `(sockperf throughput --msg-size=1024 -i $ipserverhost -p 33331 -t 10 | grep 'BandWidth is ' | cut -d ' ' -f 5)`
exit
EOF
done
# Calculate the average
echo 'Average' ',' `cat statistiques/Host_Mode_Results.xls | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` ',' `cat statistiques/Host_Mode_Results.xls | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'`>> statistiques/Host_Mode_Results.xls


paste -d"," statistiques/Node_Mode_Results.xls statistiques/Bridge_Mode_Results.xls statistiques/Host_Mode_Results.xls >> statistiques/SingleVM_Results.xls

#Data to plot 
echo '  '',' 'None'',''Bridge'',''Host'> Plot/Plot_Results.xls
echo 'TCP' ',' `cat statistiques/Node_Mode_Results.xls | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'` ',' `cat statistiques/Bridge_Mode_Results.xls | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'`',' `cat statistiques/Host_Mode_Results.xls | awk -F',' '{sum+=$2} END {print sum/(NR-1)}'`>> Plot/Plot_Results.xls
echo 'UDP' ',' `cat statistiques/Node_Mode_Results.xls | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'` ',' `cat statistiques/Bridge_Mode_Results.xls | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'`',' `cat statistiques/Host_Mode_Results.xls | awk -F',' '{sum+=$3} END {print sum/(NR-1)}'`>> Plot/Plot_Results.xls


