#!/usr/bin/env bash

function menu() 
{
echo -e "\033[1;31m ______________________________________________________________________________\033[0m"
echo -e "\033[1;31m|                                                                              |\033[0m"
echo -e "\033[1;31m|______________________________________________________________________________|\033[0m"

cat <<EOF
				`echo "1).设置系统代理"`
				`echo "2).查看系统代理"`
				`echo "3).清空系统代理"`
				`echo "4).退出脚本"`
EOF

read -p "请选择要使用的功能：" num
case $num in
    1)
        set_proxy
    ;;
    2)
        check_proxy
    ;;
    3)
        empty_proxy
	;;
	4)
        exit
    ;;
esac

}
:<<!
function check_ip() {
    VALID_CHECK=$(echo $ip|awk -F. '$1<=255&&$2<=255&&$3<=255&&$4<=255{print "yes"}')   
    if echo $ip|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" >/dev/null; then   
        if [ $VALID_CHECK == "yes" ]; then   
         echo "ip $ip  available!"   
            return 0   
        else   
            echo "ip $ip not available!"   
            return 1   
        fi   
    else   
        echo "ip format error! The setting will be wrong."   
        return 1   
    fi
}
while  true ;  do
     read  -p  "Please enter IP: "  IP
     check_ip $IP
     [ $? - eq  0 ] &&  break
done

!

:<<!
function check_port() {
  if [ "$port" -gt 0 ] 2>/dev/null ;then
    echo "port $port is number."
    else
      echo "port format error! the setting will be wrong."
  fi	
}
while  true ;  do
     read  -p  "Please enter IP: "  IP
     check_ip $IP
     [ $? - eq  0 ] &&  break
done

!

function set_proxy(){
:<<!
	read  -p  "Please enter IP: "  ip
	check_ip $IP

	read  -p  "Please enter port: "  port
	check_ip $port
!
	echo "Please enter IP:PORT, example as 134.175.228.161:50000"
	echo "IF the format is error as well as the setting will be wrong too."
    read  -p  "Please enter IP:PORT: "  ip_port
	sed -i '/http/d' /etc/profile
#	sed -i '/unset -f pathmunge/a export http_proxy=http://$ip:$port' /etc/profile
#	sed -i '/unset -f pathmunge/a export https_proxy=https://$ip:$port' /etc/profile
#   sed -i '/unset -f pathmunge/a export https_proxy=https://$ip:$port' /etc/profile
	# echo "export http_proxy=http://$ip:$port" >> /etc/profile
	# echo "export https_proxy=https://$ip:$port" >> /etc/profile
	echo "export http_proxy=http://$ip_port" >> /etc/profile
	echo "export https_proxy=https://$ip_port" >> /etc/profile
	check_proxy

}


function check_proxy(){
	source /etc/profile
	echo "...system proxy is below!...."
	echo $http_proxy && echo $https_proxy
	echo "...checking system proxy !..."
	curl cip.cc
	sleep 5
	exit
}


function empty_proxy(){
	sed -i '/http/d' /etc/profile
	source /etc/profile
	echo "...system proxy is empty!..."
	echo $http_proxy && echo $https_proxy
	
}
menu