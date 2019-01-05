#!/bin/sh

head -3 Results/SingleVM_Results_Latency_OSU.xls |  tail -1 > Plot/Data_Latency_Plot.txt
head -5 Results/SingleVM_Results_Latency_OSU.xls |  tail -1 >> Plot/Data_Latency_Plot.txt
head -7 Results/SingleVM_Results_Latency_OSU.xls |  tail -1 >> Plot/Data_Latency_Plot.txt
head -9 Results/SingleVM_Results_Latency_OSU.xls |  tail -1 >> Plot/Data_Latency_Plot.txt
head -11 Results/SingleVM_Results_Latency_OSU.xls |  tail -1 >> Plot/Data_Latency_Plot.txt
head -13 Results/SingleVM_Results_Latency_OSU.xls |  tail -1 >> Plot/Data_Latency_Plot.txt
head -15 Results/SingleVM_Results_Latency_OSU.xls |  tail -1 >> Plot/Data_Latency_Plot.txt
(cat Plot/Data_Latency_Plot.txt | tr '[\t]' '[,]') > Plot/Data_Latency.txt
rm Plot/Data_Latency_Plot.txt

head -2 Results/SingleVM_Results_Bandwidth_OSU.xls |  tail -1 > Plot/Data_Bandwidth_Plot.txt
head -4 Results/SingleVM_Results_Bandwidth_OSU.xls |  tail -1 >> Plot/Data_Bandwidth_Plot.txt
head -6 Results/SingleVM_Results_Bandwidth_OSU.xls |  tail -1 >> Plot/Data_Bandwidth_Plot.txt
head -8 Results/SingleVM_Results_Bandwidth_OSU.xls |  tail -1 >> Plot/Data_Bandwidth_Plot.txt
head -10 Results/SingleVM_Results_Bandwidth_OSU.xls |  tail -1 >> Plot/Data_Bandwidth_Plot.txt
head -12 Results/SingleVM_Results_Bandwidth_OSU.xls |  tail -1 >> Plot/Data_Bandwidth_Plot.txt
head -14 Results/SingleVM_Results_Bandwidth_OSU.xls |  tail -1 >> Plot/Data_Bandwidth_Plot.txt
cat Plot/Data_Bandwidth_Plot.txt | tr '[\t]' '[,]' > Plot/Data_Bandwidth.txt
rm Plot/Data_Bandwidth_Plot.txt

sudo apt-get -y install gnuplot-nox
gnuplot <<"EOF"
set output 'OSU_Single_VM_Latency.png'
set terminal png size 800,500 enhanced font "Helvetica,20"
set xlabel 'Packet size'
set ylabel 'Latency'
set yrange [0:1]
set xrange [0:4200]
set datafile separator ","
set title "OSU benchmark Latency"
plot 'Plot/Data_Latency.txt' u 2:3 w l lc 3 title 'None', 'Plot/Data_Latency.txt' u 5:6 w l lc 4 title 'Brigde','Plot/Data_Latency.txt' u 8:9 w l lc 5 title 'Host'

EOF

gnuplot <<"EOF"
set output 'OSU_Single_VM_BW.png'
set terminal png size 800,500 enhanced font "Helvetica,20"
set xlabel 'Packet size'
set ylabel 'Bandwidth'
set yrange [0:9000]
set xrange [0:4200]
set datafile separator ","
set title "OSU benchmark Bandwidth"
plot 'Plot/Data_Bandwidth.txt' u 2:3 w l lc 3 title 'None', 'Plot/Data_Bandwidth.txt' u 5:6 w l lc 4 title 'Brigde','Plot/Data_Bandwidth.txt' u 8:9 w l lc 5 title 'Host'

EOF
