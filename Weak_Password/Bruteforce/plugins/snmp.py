#coding=utf-8
import time
import threading
from printers import printPink,printGreen
from multiprocessing.dummy import Pool
from pysnmp.entity.rfc3413.oneliner import cmdgen


class snmp_burp(object):
    
    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]
        self.lines=self.config.file2list("conf/snmp.conf")

    def snmp_connect(self,ip,key):
        crack =0
        try:
            errorIndication, errorStatus, errorIndex, varBinds =\
                cmdgen.CommandGenerator().getCmd(
                    cmdgen.CommunityData('my-agent',key, 0),
                    cmdgen.UdpTransportTarget((ip, 161)),
                    (1,3,6,1,2,1,1,1,0)
                )
            if varBinds:
                crack=1
        except:
            pass
        return crack

    def snmp_l(self,ip,port):
            try:
                for data in self.lines:
                    flag=self.snmp_connect(ip,key=data)
                    if flag==1:
                        self.lock.acquire()
                        printGreen("%s snmp  has weaken password!!-----%s\r\n" %(ip,data))
                        self.result.append("%s snmp  has weaken password!!-----%s\r\n" %(ip,data))
                        self.lock.release()
                        break
                    else:
                        self.lock.acquire()
                        print "test %s snmp's scan fail" %(ip)
                        self.lock.release()
            except Exception,e:
                pass

    def run(self,ipdict,pinglist,threads,file):
        printPink("crack snmp now...")
        print "[*] start crack snmp %s" % time.ctime()
        starttime=time.time()
        pool=Pool(threads)
        for ip in pinglist:
            pool.apply_async(func=self.snmp_l,args=(str(ip).split(':')[0],""))

        pool.close()
        pool.join()

        print "[*] stop crack snmp %s" % time.ctime()
        print "[*] crack snmp done,it has Elapsed time:%s " % (time.time()-starttime)
        
        for i in xrange(len(self.result)):
            self.config.write_file(contents=self.result[i],file=file) 

