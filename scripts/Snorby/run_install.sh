#!/usr/bin/env bash
# author: ym2011
# date: 2016-11-21
# version: 0.0.5
echo "it will install snorby,suricata,barnyard2 automately. so take a coffee/n"

yum install epel-release
yum -y install yum-utils
yum clean all
yum-complete-transaction --cleanup-only

sleep 60
# install dependences
yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel git-core libyaml-devel libffi-devel openssl-devel make libpcap-devel pcre-devel libyaml-devel file-devel jansson-devel nss-devel libcap-ng-devel libnet-devel tar libnetfilter_queue-devel lua-devel mysql-devel fontconfig-devel libX11-devel libXrender-devel libxml2-devel libxslt-devel qconf

# dwonload and install ImageMagick
cd /opt/
wget --no-check-certificate -t 50 https://www.imagemagick.org/download/ImageMagick-6.9.6-5.tar.gz
if [ ! -f "ImageMagick-6.9.6-5.tar.gz" ]
then
	echo "the network is unreachable.please check your network and run this script again"
else
	fs="`du -B 1M ImageMagick-6.9.6-5.tar.gz | awk '{print $1}'`"
	while [ $fs -lt 12 ];
	do
		rm -rf ImageMagick-6.9.6-5.tar.gz && echo "the network is unstable.please check your network and run this script again"
		wget --no-check-certificate -t 50 https://www.imagemagick.org/download/ImageMagick-6.9.6-5.tar.gz
		break
	done

fi
tar zxvf ImageMagick-6.9.6-5.tar.gz && cd ImageMagick-6.9.6-5
./configure && make && make install
sleep 5
ldconfig /usr/local/lib

# dwonload and install yaml
cd /opt/
wget --no-check-certificate -t 50 http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
if [ ! -f "yaml-0.1.4.tar.gz" ]
then
	echo "the network is unreachable.please check your network and run this script again"
else
	fs="`du -B 1k yaml-0.1.4.tar.gz | awk '{print $1}'`"
	while [ $fs -lt 450 ];
	do
		rm -rf yaml-0.1.4.tar.gz && echo "the network is unstable.please check your network and run this script again"
		wget --no-check-certificate -t 50 http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
		break
	done

fi

tar zxvf yaml-0.1.4.tar.gz && cd yaml-0.1.4
./configure && make && make install
sleep 5

# dwonload and install libhtp
cd /opt/
wget --no-check-certificate -t 50 -O libhtp-0.5.20.tar.gz https://codeload.github.com/OISF/libhtp/tar.gz/0.5.20 
tar zxvf libhtp-0.5.20.tar.gz && cd libhtp-0.5.20
./autogen.sh
./configure && make && make install
sleep 10

# configure mysql
# yum install mysql mysql-devel mysql*
service mysqld start
chkconfig mysqld on       
/usr/bin/mysqladmin -u root password 'yymm2011@!@'

# install ruby
cd /opt/
curl -L get.rvm.io | bash -s stable
sleep 10
command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
source /etc/profile.d/rvm.sh
sleep 10
rvm install 2.0.0
sleep 20
ruby -v
sleep 20
gem install bundler
sleep 20
# dwonload and install snorby
cd /opt/ && git clone git://github.com/Snorby/snorby.git 
cd /opt/snorby/

# modify the file Gemfile,gem 'rake', '0.9.2' --->> gem 'rake', '> 0.9.2'
# sed -i 's/0.9.2/>0.9.2.2/g' Gemfile

# modify Gemfile.lock, rake (0.9.2) --->> rake(0.9.2.2)
# sed -i 's/\(0.9.2\)/0.9.2.2/g' Gemfile.lock

# create snorby_config.yml and database.yml
cp ./config/snorby_config.yml.example ./config/snorby_config.yml
cp ./config/database.yml.example ./config/database.yml
 
# modify snorby_config.yml，we can choose to delete the symbol #, 
# which is thefront of the time_zone，and change UTC to Asia/Shanghai
#  open database.yml, change the account and password to our own. here is root/ ym2011@2011my.
sed -i 's/root/snorbyroot/g 'config/database.yml 
sed -i 's/Enter Password Here/ym2011@2011my/g' config/database.yml
# change into snorby，execute the following commands to startinstallation.
# since we don't need postgreSQL, we are better to delete the library,
# or else it would go wrong whlie installing.
sed -i '/dm-postgres-adapter/d' Gemfile
bundle install

# set iptables
# /etc/init.d/iptables stop	#we can stop the iptables( nor recommended), and then access to http://ip:3000
iptables -I INPUT -p tcp --dport 3000 -m state --state=NEW,ESTABLISHED,RELATED -j ACCEPT

# dwonload and install barnyard2
cd /opt/ && wget --no-check-certificate -t 50 -O barnyard2-2-1.13.tar.gz https://codeload.github.com/firnsy/barnyard2/tar.gz/v2-1.13
if [ ! -f "barnyard2-2-1.13.tar.gz" ]
then
	echo "the network is unreachable.please check your network and run this script again"
else
	fs="`du -B 1k barnyard2-2-1.13.tar.gz | awk '{print $1}'`"
	while [ $fs -lt 400 ];
	do
		rm -rf barnyard2-2-1.13.tar.gz && echo "the network is unstable.please check your network and run this script again"
		wget --no-check-certificate -t 50 -O barnyard2-2-1.13.tar.gz https://codeload.github.com/firnsy/barnyard2/tar.gz/v2-1.13
		break
	done

fi

tar xvfz barnyard2-2-1.13.tar.gz && cd barnyard2-2-1.13/
./autogen.sh
./configure --with-mysql-libraries=/usr/lib64/mysql/ --with-mysql=/usr/bin/mysql
make && make install

# dwonload and install Suricata 
cd /opt/ && wget -t 50 http://www.openinfosecfoundation.org/download/suricata-3.1.tar.gz
if [ ! -f "suricata-3.1.tar.gz" ]; then
	echo "the network is unreachable.please check your network and run this script again"
else
	fs1="`du -B 1M suricata-3.1.tar.gz | awk '{print $1}'`"
	if [ $fs1 -lt 3 ]; then
			rm -rf suricata-3.1.tar.gz && echo "the network is unstable.please check your network and run this script again"
			
	fi

fi
tar -xvzf suricata-3.1.tar.gz && cd suricata-3.1
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-nfqueue --enable-lua
make && make install-full

echo " congratulations!, snorby、suricata、barnyard2 is fullly installed. "
echo " we will configure the configuration files automatically."
echo " please wait a minute"

# configure Suricata、Barnyard 2
# copy etc/barnyard2.con in barnyard2-2-1.13 directory to Suricata configuration directory
cd /opt/barnyard2-2-1.13
cp ./etc/barnyard2.conf /etc/suricata/

#create barnyard2 log directory named /var/log/barnyard2
mkdir /var/log/barnyard2

# change barnyard2.conf
# change the default snort file configuration to suricata
sed -i 's/snort/suricata/g' /etc/suricata/barnyard2.conf
sed -i 's/gen-msg.map/rules\/gen-msg.map/g' /etc/suricata/barnyard2.conf
sed -i 's/sid-msg.map/rules\/sid-msg.map/g' /etc/suricata/barnyard2.conf

# add the MySQL information to barnyard2.conf
sed -i '$a output database: log, mysql, user=snorbroot password=ym2011@2011my dbname=snorby host=localhost' /etc/suricata/barnyard2.conf

# find out the string “config hostname” and “config
# interface”，is to monitor the traffic, it can be more than one.
# match this string and add a new line next.
sed -i -e '/#config hostname:   thor/a\config hostname:   ym/' /etc/suricata/barnyard2.conf
sed -i -e '/#config interface:  eth0/a\config interface:  eth0/' /etc/suricata/barnyard2.conf
sed -i -e '/#config waldo_file/a\config waldo_file: /var/log/suricata/suricata.waldo' /etc/suricata/barnyard2.conf

# edit suricata.yaml
touch /var/log/suricata/suricata.waldo

# modify log format fled:
# match this string and add a new line next.
sed -i -e '/default-log-format/a\  default-log-format: "[%i] %t -(%f:%l) <%d> (%n) -- "' /etc/suricata/suricata.yaml

# figure out #pid-file: /var/run/suricata.pid, and drop the #
# match this string and add a new line next.
sed -i -e '/pid-file/a\pid-file: /var/run/suricata.pid' /etc/suricata/suricata.yaml

#  figure out #threshold-file: /etc/suricata/threshold.config,and drop the "#"
sed -i -e '/threshold-file/a\threshold-file: /etc/suricata/threshold.config' /etc/suricata/suricata.yaml

# enable syslog function, in /etc/suricata/suricata.yaml ， find out 
# match and replace the word no to yes between string"/var/log/suricata/suricata.log/" and "Step 4"
sed -i -e '\/var\/log\/suricata\/suricata.log/,/Step 4/s/no/yes/g' /etc/suricata/suricata.yaml

# enable unified2 logging in the suricata yaml:
# match and replace the word no to yes between string " unified2-alert " and " unified2.alert " 
sed -i -e '/unified2-alert/,/unified2.alert/s/no/yes/g' /etc/suricata/suricata.yaml

echo " congratulations!, all configurations is fullly finished. "
echo " we will do modify and add a user for snorby in MySQL"
# we add a user for snorby in MySQL.
echo " if some steps went wrong and then do the command one by one. "
mysql -uroot -pyymm2011@!@ <<EOF
create user 'snorbyroot'@'localhost' identified by 'ym2011@2011my';
grant all privileges on snorby.* to 'snorbyroot'@'localhost' with grant option;
flush privileges;
quit
EOF

echo " script executed successful.if errors occurs, please run the command above on your own"
echo " please run the file: start-ids.sh to start the service "
echo " have fun ! "




