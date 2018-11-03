#coding=utf-8
__author__ = 'wilson'
from IPy import IP
from comm.printers import printPink,printRed,printGreen

class config(object):
	
	def getips(self,ip):
		iplist=[]
		try:
			if "-" in ip.split(".")[3]:
				startnum=int(ip.split(".")[3].split("-")[0])
				endnum=int(ip.split(".")[3].split("-")[1])
				for i in range(startnum,endnum):
					iplist.append("%s.%s.%s.%s" %(ip.split(".")[0],ip.split(".")[1],ip.split(".")[2],i))
			else:
				ips=IP(ip)
				for i in ips:
					iplist.append(str(i))
			
			return iplist

		except:
			printRed("[!] not a valid ip given. you should put ip like 192.168.1.0/24, 192.168.0.0/16,192.168.0.1-200")
			exit()


	def file2list(self,file):
		iplist=[]
		try:
			fh = open(file)
			for ip in fh.readlines():
				ip=ip.strip()
				iplist.append(ip)
			fh.close()
			return iplist
		except Exception, e:
			print e
			exit()


	def write_file(self,file,contents):
	    f2 = open(file,'a+')
	    f2.write(contents)
	    f2.close()