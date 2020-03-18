#coding=utf-8
__author__ = 'wilson'
import argparse
from comm.printers import printPink,printRed,printGreen
from comm.config import *
from comm.portscan import *
from factorys.pluginFactory import *


#实例化config类
c=config()

if __name__ == '__main__':
    #接受cmd参数
    parser = argparse.ArgumentParser(description='ports&*weak password scanner. teams:xdsec.  author: wilson ')
    parser.add_argument('--ip',action="store",required=False,dest="ip",type=str,help='ip like 192.168.1.0/24 or 192.168.0.0/16')
    parser.add_argument("--threads",action="store",required=False,dest="threads",type=int,default=50,help='Maximum threads, default 50')
    parser.add_argument("--P",action="store",required=False,dest="isping",type=str,default='yes',help='--P not mean no ping frist,default yes')
    parser.add_argument("--p",action="store",required=False,dest="user_ports",type=str,default='',help='--p scan ports;like 21,80,445 or 22-1000')
    parser.add_argument("--file",action="store",required=False,dest="file",type=str,help='get ips or domains for this file')

    args = parser.parse_args()
    ip = args.ip
    filename=args.file


    #获取ip列表
    if ip:
        ips=c.getips(ip)
        file="result/%s.txt" %args.ip.replace("/","")
    elif filename:
        ips=c.file2list(filename)
        filename=filename.split("/")[-1]
        file="result/%s.txt" %filename
    else:
        print "error args";exit()

    isping=args.isping
    user_posts=args.user_ports
    threads=args.threads

    p=portscan(c,user_posts)
    p.run(isping,threads,ips,file)

    #print p.ipdict,p.pinglist
    plugins=pluginFactory(c)
    for pluginname in plugins.pluginList:
        #print pluginname
        if pluginname:
            pluginname.run(p.ipdict,p.pinglist,threads,file)



