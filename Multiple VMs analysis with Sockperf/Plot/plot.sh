#!/bin/sh

sudo apt-get -y install gnuplot-nox
gnuplot <<'EOF'
set terminal png size 800,500 enhanced font "Helvetica,20"
set output 'Sockperf_throughput_Single_VM.png'
red = "#FF0000"; green = "#00FF00"; blue = "#0000FF"; skyblue = "#87CEEB";
set yrange [0:1000]
set style data histogram
set style histogram cluster gap 1
set style fill solid
set boxwidth 0.9
set xtics format ""
set grid ytics
set datafile separator ","
set title "Sockperf throughput Single VM"
plot "Plot_Results.xls" using 2:xtic(1) title "None" linecolor rgb red, \
            '' using 3 title "Bridge" linecolor rgb blue, \
            '' using 4 title "Host" linecolor rgb green, \
EOF
