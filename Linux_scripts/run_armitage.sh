#!/bin/bash
echo "execute the script to run armitage,typ the following command in the terminal:
chmod 755 run_armitage.sh
./run_armitage.sh"
echo -e "if you want to the new verison of metasploit， please type:
apt-get update && apt-get upgrade"
echo " have fun !!!^-^"
echo -e "if there are any problem, please see the Armitage-FAQ.txt
the link is :
https://github.com/ym2011/penetration/blob/master/Armitage-FAQ.txt"
service postgresql start
armitage &
