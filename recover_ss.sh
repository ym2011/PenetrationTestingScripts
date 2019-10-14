#!/bin/bash
# author	：ym2011
# date		: 2019-10-08
# version 	: 1.0
# target 	: After restored Snapshots to the machine, the script helps to correct the configuration easily.

default_install(){
#Recover the backup configuration for shadowsocks
	echo
	echo_Yellow "# ======================================="
	echo_GreenBG "Stop Shadowsocks service "
	systemctl stop shadowsocks
    # open ports for ss server 
	echo
	echo_Yellow "# ======================================="
	echo_GreenBG "Add ports of shadowsocks to system firewall "
	firewall-cmd --zone=public --add-port=25/tcp --permanent
	firewall-cmd --zone=public --add-port=2019/tcp --permanent
	firewall-cmd --reload
	# Get public IP address
	echo_GreenBG "Change the ip in Configuration for shadowsocks"
	IP=$(/sbin/ifconfig eth0 | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |head -n 1)
	# change the IP for current machine 
    sed -i '3s/^.*$/"server": "'$IP'",/g' /etc/shadowsocks.json
    # reload 
	echo
	echo_Yellow "# ======================================="
	echo_GreenBG "Show the status for Shadowsocks "
	systemctl daemon-reload
	systemctl start shadowsocks
	systemctl status shadowsocks -l
}


restart_service(){
	echo
	echo_Yellow "# ======================================="
	echo_GreenBG "restart Shadowsocks "
	systemctl stop shadowsocks
	systemctl start shadowsocks
	echo_GreenBG "Show the status for Shadowsocks "
	systemctl status shadowsocks -l
}


show_status(){
	echo
	echo_Green "# ======================================="
	echo_GreenBG "show the status for bbr "
	lsmod | grep bbr
	echo
	echo_Green "# ======================================="
	echo_GreenBG "show the status for Shadowsocks "
	systemctl status shadowsocks -l
}


display_conf(){
    echo
    echo
    echo_Green "# ======================================="
    echo_GreenBG "#Shadowsocks Server Configuration: /etc/shadowsocks.json"
    cat /etc/shadowsocks.json
	echo
	echo_Green "# ======================================="
    echo_GreenBG "#bbr Server Configuration: /etc/sysctl.conf"
    cat /etc/sysctl.conf | grep bbr
	
}



# Setting Menu
start_menu(){
    clear
	echo
	echo_Green "# ======================================="
	echo "Firstly, creating the machine and Restored Snapshot."
	echo "Secondly, We should correct the configuration for shadowsocks."
	echo "Finally, Following the guide, it can help you do it easily!!!"
	echo
	echo_Green "# ======================================="
    echo_SkyBlue ">  1. Default Option, Recover Shadowsocks and bbr automatically  "
	echo_Green "# ======================================="
	echo_SkyBlue ">  2. Restart Shadowsocks service "
	echo_Green 	 ">  3. Display status for Shadowsocks and bbr "
	echo_Green   ">  4. Display Shadowsocks and bbr Configuration "
    echo_Yellow  ">  5. Exit"
    read -p "Please Enter the Number to Choose (Press Enter to Default):" num
    case "$num" in
        1)
        default_install
        ;;
	2)
	restart_service
        ;;
        3)
        show_status
	;;
	4)
        display_conf
        ;;
        5)
        exit 1
        ;;
        *)
        default_install
        ;;
        esac
}


# Definition Display Text Color
Green="\033[32m"  && Red="\033[31m" && GreenBG="\033[42;37m" && RedBG="\033[41;37m"
Font="\033[0m"  && Yellow="\033[0;33m" && SkyBlue="\033[0;36m"

echo_SkyBlue(){
    echo -e "${SkyBlue}$1${Font}"
}
echo_Yellow(){
    echo -e "${Yellow}$1${Font}"
}
echo_Green(){
    echo -e "${Green}$1${Font}"
}
echo_GreenBG(){
    echo -e "${GreenBG}$1${Font}"
}



start_menu
