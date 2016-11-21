#!/usr/bin/env bash
# author: ym2011
# date: 2016-11-21
# version: 0.0.2
echo "it will install snorby,suricata,barnyard2 automately. so take a coffee/n"

yum install epel-release
sleep 120
# install dependences
yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel git-core libyaml-devel libffi-devel openssl-devel make libpcap-devel pcre-devel libyaml-devel file-devel jansson-devel nss-devel libcap-ng-devel libnet-devel tar libnetfilter_queue-devel lua-devel mysql-devel fontconfig-devel libX11-devel libXrender-devel libxml2-devel libxslt-devel qconf

# dwonload and install ImageMagick
cd /opt/
wget --no-check-certificate -t 50 https://www.imagemagick.org/download/ImageMagick-6.9.6-5.tar.gz
tar zxvf ImageMagick-6.9.6-5.tar.gz && cd ImageMagick-6.9.6-5
sleep 10
./configure && make && make install
sleep 10
ldconfig /usr/local/lib

# dwonload and install yaml
cd /opt/
wget --no-check-certificate -t 50 http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
tar zxvf yaml-0.1.4.tar.gz && cd yaml-0.1.4
./configure && make && make install

# dwonload and install libhtp
cd /opt/
wget --no-check-certificate -t 50 -O libhtp-0.5.20.tar.gz https://codeload.github.com/OISF/libhtp/tar.gz/0.5.20 
tar zxvf libhtp-0.5.20.tar.gz && cd libhtp-0.5.20
./autogen.sh
./configure && make && make install

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
ruby -v

gem install bundler

# dwonload and install snorby
cd /opt/ && git clone git://github.com/Snorby/snorby.git && cd snorby

# 修改文件Gemfile,把gem 'rake', '0.9.2'   改成  gem 'rake', '> 0.9.2'
# sed -i 's/0.9.2/>0.9.2.2/g' Gemfile

# 修改文件Gemfile.lock,把 rake (0.9.2)  改成  rake(0.9.2.2)
# sed -i 's/\(0.9.2\)/0.9.2.2/g' Gemfile.lock

# 创建snorby_config.yml和database.yml两个文件
cp config/snorby_config.yml.example config/snorby_config.yml
cp config/database.yml.example config/database.yml
 
# 修改snorby_config.yml，把time_zone前面的注释去掉，并把UTC改为Asia/Shanghai
# 打开database.yml 把里面 mysql的账号密码修改成我们设置的账号密码（root/ ym2011@2011my)
sed -i 's/root/snorbyroot/g 'config/database.yml 
sed -i 's/Enter Password Here/ym2011@2011my/g' config/database.yml
# 进入snorby目录，执行如下命令开始安装：
# 因为我们不需要postgreSQL, 所以要删除该库，否则编译会出错。
sed -i '/dm-postgres-adapter/d' Gemfile
bundle install

# 设置iptables
# /etc/init.d/iptables stop	#关闭防火墙，其他主机可以访问http://ip:3000
iptables -I INPUT -p tcp --dport 3000 -m state --state=NEW,ESTABLISHED,RELATED -j ACCEPT

# dwonload and install barnyard2
cd /opt/ && wget wget --no-check-certificate -t 50 -O barnyard2-2-1.13.tar.gz https://codeload.github.com/firnsy/barnyard2/tar.gz/v2-1.13
tar xvfz barnyard2-2-1.13.tar.gz && cd barnyard2-2-1.13/
./autogen.sh
./configure --with-mysql-libraries=/usr/lib64/mysql/ --with-mysql=/usr/bin/mysql
make && make install


# dwonload and install Suricata 
cd /opt/ && wget -t 50 http://www.openinfosecfoundation.org/download/suricata-3.1.tar.gz
tar -xvzf suricata-3.1.tar.gz && cd suricata-3.1
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-nfqueue --enable-lua
make && make install-full

# configure Suricata、Barnyard 2
#把Barnyard 2安装源文件中的etc/barnyard2.conf文件拷贝到Suricata的配置目录
cd /opt/barnyard2-2-1.13
cp ./etc/barnyard2.conf /etc/suricata/

#创建barnyard2日志目录/var/log/barnyard2
mkdir /var/log/barnyard2

# 修改barnyard2.conf
# 把 默认的snort文件配置改成 suricata
sed -i 's/snort/suricata/g' /etc/suricata/barnyard2.conf
sed -i 's/gen-msg.map/rules\/gen-msg.map/g' /etc/suricata/barnyard2.conf
sed -i 's/sid-msg.map/rules\/sid-msg.map/g' /etc/suricata/barnyard2.conf

# 把数据信息添加到barnyard2.conf  //已完成
sed -i '$a output database: log, mysql, user=snorbroot password=ym2011@2011my dbname=snorby host=localhost' /etc/suricata/barnyard2.conf

#找到“config hostname”和“config interface”，eth0是镜像端口所在的网卡，按照你的实际情况修改.(unfinished)
#匹配到该字符串，在匹配行的下面添加新的一行字符串
sed -i -e '/#config hostname:   thor/a\config hostname:   ym/' /etc/suricata/barnyard2.conf
sed -i -e '/#config interface:  eth0/a\config interface:  eth0/' /etc/suricata/barnyard2.conf
sed -i -e '/#config waldo_file/a\config waldo_file: /var/log/suricata/suricata.waldo' /etc/suricata/barnyard2.conf

# 编辑suricata.yaml文件
touch /var/log/suricata/suricata.waldo

# 修改日志格式文件:
#匹配到该字符串，在匹配行的下面添加新的一行字符串
sed -i -e '/default-log-format/a\  default-log-format: "[%i] %t -(%f:%l) <%d> (%n) -- "' /etc/suricata/suricata.yaml

# 找到#pid-file: /var/run/suricata.pid把前面的#号去掉
#匹配到该字符串，在匹配行的下面添加新的一行字符串
sed -i -e '/pid-file/a\pid-file: /var/run/suricata.pid' /etc/suricata/suricata.yaml

# 启用 threshold，找到#threshold-file: /etc/suricata/threshold.config
#匹配到该字符串threshold-file，在匹配行的下面添加新的一行字符串
sed -i -e '/threshold-file/a\threshold-file: /etc/suricata/threshold.config' /etc/suricata/suricata.yaml

# 开启syslog 功能, 在/etc/suricata/suricata.yaml ， 找到：
# 匹配并替换在字符串/var/log/suricata/suricata.log/，Step 4之间的内容，把enabled: no 改成 enabled: yes
sed -i -e '\/var\/log\/suricata\/suricata.log/,/Step 4/s/no/yes/g' /etc/suricata/suricata.yaml

# 开启unified2 logging in the suricata yaml:
# 匹配并替换在字符串unified2-alert， unified2.alert之间的内容，把enabled: no 改成 enabled: yes
sed -i -e '/unified2-alert/,/unified2.alert/s/no/yes/g' /etc/suricata/suricata.yaml

echo "you should do the following steps on your own~~*_*~~~"
echo " the password of root in mysql is /yymm2011@!@"
echo " mysql -u root -p "
echo " create user 'snorbyroot'@'localhost' IDENTIFIED BY 'ym2011@2011my'; "
echo " grant all privileges on snorby.* to 'snorbyroot'@'localhost' with grant option; "
echo " flush privileges; "
echo " please run the file: start-ids.sh to start the service "
echo " have fun ! "












