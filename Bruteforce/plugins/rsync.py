# -*- coding: utf-8 -*-
import threading
from printers import printPink,printRed,printGreen
from multiprocessing.dummy import Pool
from Queue import Queue
import re
import time
import threading
from threading import Thread
from rsynclib import *
import sys
import socket
socket.setdefaulttimeout(10)
sys.path.append("../")

class rsync_burp(object):

    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]
        self.sp=Queue()

    def get_ver(self,host):
        debugging = 0
        r = rsync(host)
        r.set_debuglevel(debugging)
        return r.server_protocol_version


    def rsync_connect(self,ip,port):
        creak=0
        try:
            ver=self.get_ver(ip)# get rsync moudle
            fp = socket.create_connection((ip, port), timeout=8)
            fp.recv(99)

            fp.sendall(ver.strip('\r\n')+'\n')
            time.sleep(3)
            fp.sendall('\n')
            resp = fp.recv(99)

            modules = []
            for line in resp.split('\n'):
                #print line
                modulename = line[:line.find(' ')]
                if modulename:
                    if modulename !='@RSYNCD:':
                        self.lock.acquire()
                        printGreen("%s rsync at %s find a module:%s\r\n" %(ip,port,modulename))
                        self.result.append("%s rsync at %s find a module:%s\r\n" %(ip,port,modulename))               
                        #print "find %s module in %s at %s" %(modulename,ip,port)
                        self.lock.release()
                        modules.append(modulename)

        except Exception,e:
            print e
            pass
        return creak


    def rsync_creak(self,ip,port):
            try:
                self.rsync_connect(ip,port)
            except Exception,e:
                print e


    def run(self,ipdict,pinglist,threads,file):
        if len(ipdict['rsync']):
            printPink("crack rsync  now...")
            print "[*] start crack rsync  %s" % time.ctime()
            starttime=time.time()

            pool=Pool(threads)

            for ip in ipdict['rsync']:
                pool.apply_async(func=self.rsync_creak,args=(str(ip).split(':')[0],int(str(ip).split(':')[1])))
            pool.close()
            pool.join()

            print "[*] stop rsync serice  %s" % time.ctime()
            print "[*] crack rsync done,it has Elapsed time:%s " % (time.time()-starttime)

            for i in xrange(len(self.result)):
                self.config.write_file(contents=self.result[i],file=file) 


if __name__ == '__main__':
    from comm.config import *
    c=config()
    ipdict={'rsync': ['103.228.69.151:873']} 
    pinglist=['103.228.69.151']
    test=rsync_burp(c)
    test.run(ipdict,pinglist,50,file="../result/test")

                
