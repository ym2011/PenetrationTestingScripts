#!/bin/bash
#
# rdpScan - scan a network segment for RDP-Server          
# author: silverstoneblue@gmx.net	
# requires:  fgrep awk nmap

scriptname="rdpScan"
version="1.0"
rdpips="/tmp/tmprdp.$$"

declare -i rdpfound=0

function is_installed {
  which $1 > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    printf "\nERROR: %s not installed.\n\n" $1
    exit 255
  fi
}
 
is_installed fgrep
is_installed awk
is_installed nmap

	if [ $# -ne 1 ]; then
  		printf "\n \n"
 		printf "rdpScan - scan a network segment for RDP-Server \n\n"
  		printf "version %s by silverstoneblue@gmx.net \n\n" $version
 		printf "Usage: %s {target network}\n\n" $scriptname
  		printf "target network:\n"
  		printf "  can pass hostnames, IP's, networks, etc.\n"
  		printf "  server.company.com, company.com/24, 192.168.0.1/16, 10.0.0-255.1-254\n"
  		printf "example:\n"
  		printf "  %s 80.187.0.0/24\n\n" $scriptname
  		exit 255
	fi
 
iprange=$1
 
printf "\nScanning for RDP-Server..."
 
nmap -n -P0 -sS -p 3389 -oG - $iprange | fgrep 'Ports: 3389/open/tcp//ms-term-serv///' | awk '{print $2}' > $rdpips

printf "\n\n"

exec 3< $rdpips
 
echo "*****************"
echo "RDP IP Address"
echo "*****************"
 
	while read rdpip <&3 ; do
  		rdpfound=$rdpfound+1
  		printf "%-15s %s\n" $rdpip 
	done

	
	if [ $rdpfound -eq 0 ] ; then 
		printf "No RDP-Server found on network target %s. \n\n" $iprange
 		rm -f $rdpips 
		exit 255
	fi
	
printf "\n%d RDP-Server found on network target %s.\n" $rdpfound $iprange
printf "Now try ur luck ;)\n"
printf "have fun ;) \n"
rm -f $rdpips 
exit 0
