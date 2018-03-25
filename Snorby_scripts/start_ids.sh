#!/bin/sh
echo "==========================================================================================="
echo "it will start the snorby  first, and then will start barnyard2 and suricata later"
echo "please wait for a minute"
echo "if there are any problems, please check the barnyard2.conf and  "
cd /opt/snorby && rake snorby:setup && rails server -e production &
# cd snorby && rake snorby:setup && rails server -d -e production

/usr/local/bin/barnyard2 -c /etc/suricata/barnyard2.conf -d /var/log/suricata -f unified2.alert -w /var/log/suricata/suricata.waldo –D &

LD_LIBRARY_PATH=/usr/local/lib /usr/bin/suricata -c /etc/suricata//suricata.yaml -i eth0 -D &

echo " the service have started, please http://yourip:3000 on your browser, the ip is the machine where you install snorby. "
echo " have fun !!"
echo "==========================================================================================="
