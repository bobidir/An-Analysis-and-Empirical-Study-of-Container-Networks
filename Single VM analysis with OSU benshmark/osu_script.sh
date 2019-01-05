#!/bin/sh
#Install docker 

sudo apt-get -y update
sudo apt-get install -y docker-ce
sudo groupadd docker
sudo gpasswd -a $USER docker

echo '******************************** NONE MODE TEST ******************************************************'
sudo su <<'EOF'
apt install mpich -y
wget http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.3.2.tar.gz
tar xvzf osu-micro-benchmarks-5.3.2.tar.gz
chmod 555 osu-micro-benchmarks-5.3.2
cd osu-micro-benchmarks-5.3.2
./configure CC=/usr/bin/mpicc CXX=/usr/bin/mpicxx
apt-get -y install build-essential
apt-get install -y autoconf automake libtool -y
make 
make install
 
EOF
mkdir -m 777 Results
mkdir -m 777 Plot

# Latency
/usr/bin/mpiexec -n 2 osu-micro-benchmarks-5.3.2/mpi/pt2pt/osu_latency >  Results/results_Latency_None.txt
echo 'Packet size'',''Latency'>  Results/results_Latency_None.xls
(tail --lines=+3  Results/results_Latency_None.txt | tr -s '[:blank:]' ',') >>  Results/results_Latency_None.xls
rm  Results/results_Latency_None.txt
# Bandwidth
/usr/bin/mpiexec -n 2 osu-micro-benchmarks-5.3.2/mpi/pt2pt/osu_bw>  Results/results_Bandwidth_None.txt
echo 'Packet size'',''Bandwidth'>  Results/results_Bandwidth_None.xls
(tail --lines=+3  Results/results_Bandwidth_None.txt | tr -s '[:blank:]' ',') >>  Results/results_Bandwidth_None.xls
rm  Results/results_Bandwidth_None.txt

echo '******************************** BRIDGE MODE TEST ******************************************************'
#Create containers with bridge mode
docker run -it -d --name bridge_container_OSU ubuntu:16.04

#Install OSU inside the container

docker exec -i bridge_container_OSU bash <<'EOF'
apt-get -y update
apt install mpich -y
apt-get install wget -y
wget http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.3.2.tar.gz
tar xvzf osu-micro-benchmarks-5.3.2.tar.gz
chmod 555 osu-micro-benchmarks-5.3.2
cd osu-micro-benchmarks-5.3.2
./configure CC=/usr/bin/mpicc CXX=/usr/bin/mpicxx
apt-get -y install build-essential
apt-get install -y autoconf automake libtool -y
make 
make install
EOF
# Latency
docker exec -i bridge_container_OSU /bin/bash << 'EOF'
cd /
cd osu-micro-benchmarks-5.3.2/mpi/pt2pt
(/usr/bin/mpiexec -n 2 ./osu_latency) > ~/results_Latency_Bridge.txt && (echo 'Packet size'',''Latency' > ~/results_Latency_Bridge.xls) && ((tail --lines=+3 ~/results_Latency_Bridge.txt | tr -s '[:blank:]' ',') >> ~/results_Latency_Bridge.xls) && exit
EOF
docker exec -i bridge_container_OSU /bin/bash << 'EOF' >>  Results/results_Latency_Bridge.xls
cd 
cat ~/results_Latency_Bridge.xls
EOF
# Bandwidth
docker exec -i bridge_container_OSU /bin/bash << 'EOF'
cd /
cd osu-micro-benchmarks-5.3.2/mpi/pt2pt
/usr/bin/mpiexec -n 2 ./osu_bw > ~/results_Bandwidth_Bridge.txt && (echo 'Packet size'',''Bandwidth' > ~/results_Bandwidth_Bridge.xls) && (tail --lines=+3 ~/results_Bandwidth_Bridge.txt | tr -s '[:blank:]' ',' >> ~/results_Bandwidth_Bridge.xls) && exit
EOF
docker exec -i bridge_container_OSU /bin/bash << 'EOF' >>  Results/results_Bandwidth_Bridge.xls
cd 
cat ~/results_Bandwidth_Bridge.xls
EOF

echo '******************************** HOST MODE TEST ******************************************************'
#Create containers with host mode
docker run -it -d --name host_container_OSU --network host ubuntu:16.04

#Install OSU inside the container

docker exec -i host_container_OSU bash <<'EOF'
apt-get -y update
apt install mpich -y
apt-get install wget -y
wget http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.3.2.tar.gz
tar xvzf osu-micro-benchmarks-5.3.2.tar.gz
chmod 555 osu-micro-benchmarks-5.3.2
cd osu-micro-benchmarks-5.3.2
./configure CC=/usr/bin/mpicc CXX=/usr/bin/mpicxx
apt-get -y install build-essential
apt-get install -y autoconf automake libtool -y
make 
make install
EOF
# Latency
docker exec -i host_container_OSU /bin/bash << 'EOF'
cd /
cd osu-micro-benchmarks-5.3.2/mpi/pt2pt
/usr/bin/mpiexec -n 2 ./osu_latency > ~/results_Latency_Host.txt && (echo 'Packet size'',''Latency' > ~/results_Latency_Host.xls) && (tail --lines=+3 ~/results_Latency_Host.txt | tr -s '[:blank:]' ',' >> ~/results_Latency_Host.xls) && exit
EOF
docker exec -i host_container_OSU /bin/bash << 'EOF' >>  Results/results_Latency_Host.xls
cd 
cat ~/results_Latency_Host.xls
EOF
# Bandwidth
docker exec -i host_container_OSU /bin/bash << 'EOF'
cd /
cd osu-micro-benchmarks-5.3.2/mpi/pt2pt
/usr/bin/mpiexec -n 2 ./osu_bw> ~/results_Bandwidth_Host.txt && (echo 'Packet size'',''Bandwidth' > ~/results_Bandwidth_Host.xls) && (tail --lines=+3 ~/results_Bandwidth_Host.txt | tr -s '[:blank:]' ',' >> ~/results_Bandwidth_Host.xls) && exit
EOF
docker exec -i host_container_OSU /bin/bash << 'EOF' >>  Results/results_Bandwidth_Host.xls
cd 
cat ~/results_Bandwidth_Host.xls
EOF
#************************************* FINAL RESULTS ***********************************************************************************************
# Lantency

echo 'Mode'>  Results/results_Latency_NoneMode.xls
for i in `seq 1 24`
do
(echo 'None') >>  Results/results_Latency_NoneMode.xls
done

(paste  Results/results_Latency_NoneMode.xls  Results/results_Latency_None.xls) >  Results/results_Latency_NoneModeFinal.xls

rm  Results/results_Latency_NoneMode.xls  Results/results_Latency_None.xls

echo 'Mode'>  Results/results_Latency_BridgeMode.xls
for i in `seq 1 24`
do
(echo 'Bridge') >>  Results/results_Latency_BridgeMode.xls
done
(paste  Results/results_Latency_BridgeMode.xls  Results/results_Latency_Bridge.xls) >  Results/results_Latency_BridgeModeFinal.xls
rm  Results/results_Latency_Bridge.xls  Results/results_Latency_BridgeMode.xls

echo 'Mode'>  Results/results_Latency_HostMode.xls
for i in `seq 1 24`
do
(echo 'Host') >>  Results/results_Latency_HostMode.xls
done
(paste  Results/results_Latency_HostMode.xls  Results/results_Latency_Host.xls) >  Results/results_Latency_HostModeFinal.xls
rm  Results/results_Latency_Host.xls  Results/results_Latency_HostMode.xls


(paste -d","  Results/results_Latency_NoneModeFinal.xls  Results/results_Latency_BridgeModeFinal.xls  Results/results_Latency_HostModeFinal.xls) >  Results/SingleVM_Results_Latency_OSU.xls

rm  Results/results_Latency_NoneModeFinal.xls  Results/results_Latency_BridgeModeFinal.xls  Results/results_Latency_HostModeFinal.xls

# Bandwidth



echo 'Mode'>  Results/results_Bandwidth_NoneMode.xls
for i in `seq 1 23`
do
(echo 'None') >>  Results/results_Bandwidth_NoneMode.xls
done
(paste  Results/results_Bandwidth_NoneMode.xls  Results/results_Bandwidth_None.xls) >  Results/results_Bandwidth_NoneModeFinal.xls
rm  Results/results_Bandwidth_None.xls  Results/results_Bandwidth_NoneMode.xls

echo 'Mode'>  Results/results_Bandwidth_BridgeMode.xls
for i in `seq 1 23`
do
(echo 'Bridge') >>  Results/results_Bandwidth_BridgeMode.xls
done
(paste  Results/results_Bandwidth_BridgeMode.xls  Results/results_Bandwidth_Bridge.xls) >  Results/results_Bandwidth_BridgeModeFinal.xls
rm  Results/results_Bandwidth_Bridge.xls  Results/results_Bandwidth_BridgeMode.xls

echo 'Mode'>  Results/results_Bandwidth_HostMode.xls
for i in `seq 1 23`
do
(echo 'Host') >>  Results/results_Bandwidth_HostMode.xls
done
paste  Results/results_Bandwidth_HostMode.xls  Results/results_Bandwidth_Host.xls >  Results/results_Bandwidth_HostModeFinal.xls
rm  Results/results_Bandwidth_Host.xls  Results/results_Bandwidth_HostMode.xls

paste -d","  Results/results_Bandwidth_NoneModeFinal.xls  Results/results_Bandwidth_BridgeModeFinal.xls  Results/results_Bandwidth_HostModeFinal.xls >  Results/SingleVM_Results_Bandwidth_OSU.xls

rm  Results/results_Bandwidth_NoneModeFinal.xls  Results/results_Bandwidth_BridgeModeFinal.xls  Results/results_Bandwidth_HostModeFinal.xls
sudo rm osu-micro-benchmarks-5.3.2.tar.gz
sudo rm -rf osu-micro-benchmarks-5.3.2

