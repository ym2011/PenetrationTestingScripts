#!/bin/sh
echo "==========================================================================================="
echo "it will stop the snorby  first, and then will stop barnyard2 and suricata later"
echo "please wait for a minute"

kill -9 `ps -ef | grep /bin/ruby | grep rails | awk '{print $2}'`

kill -9 `ps -ef | grep /usr/local/bin/barnyard2 | awk '{print $2}'`

kill -9 `ps -ef | grep /usr/bin/suricata | awk '{print $2}'`

echo " the service have stop, if you want to restart the snorby + barnyard2 + suricata once, please run :./start-ids.sh "
echo " Bye"
echo "==========================================================================================="
