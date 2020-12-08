# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
#
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
#
# For more information see the manual pages of crontab(5) and cron(8)
#
#root@kali:/# crontab -u root /root/batchaccess 
#
#root@kali:/# siege -i -c 300 -r 20 -t 2H -b -v -f /root/blog.txt
#root@kali:/# leafpad /etc/siege/siegerc
#root@kali:/# siege -C
#root@kali:/# locate siege
#
#
#root@kali:~# crontab -u root /root/batchaccess#使用root用户定时执行 /root/batchaccess 这个文件
#root@kali:~# crontab -u root -l# 列出 root用户的定时任务
#root@kali:~# crontab -u root -r# 清空 root用户的定时任务
#root@kali:~#  crontab -u root -i -r # 在清空 root用户的定时任务之前，需要用户手动确认是否清空
#
#root@kali:/# locate siege
#root@kali:/# leafpad /var/log/siege.log 
#root@kali:/# cat /var/log/syslog |grep "siege" 
#root@kali:/# rm /var/log/siege.log
#
#root@kali:~# /etc/init.d/cron restart
#root@kali:~# service cron restart
#


*/2 * * * * siege -i -c 100 -t 20S -v -f /root/blog.txt
