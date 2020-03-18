from printers import printPink,printGreen
import time
import threading
from multiprocessing.dummy import Pool
from vnclib import *


class vnc_burp(object):


    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]
        self.lines=self.config.file2list("conf/vnc.conf")

    def vnc_connect(self,ip,port,password):
        crack =0
        try:
            v = VNC()
            v.connect(ip, port, 10)
            code,mesg=v.login(password)
            if mesg=='OK':
                crack=1
        except Exception,e:
            crack=2
            pass
        return crack

    def vnc_l(self,ip,port):
            try:
                for data in self.lines:
                    flag=self.vnc_connect(ip=ip,port=port,password=data)
                    if flag==2:
                        self.lock.acquire()
                        print "%s vnc at %s not allow connect now because of too many security failure" %(ip,port)
                        self.lock.release()
                        break

                    if flag==1:
                        self.lock.acquire()
                        printGreen("%s vnc at %s has weaken password!!-----%s\r\n" %(ip,port,data))
                        self.result.append("%s vnc at %s  has weaken password!!-----%s\r\n" %(ip,port,data))
                        self.lock.release()
                        break
                    else:
                        self.lock.acquire()
                        print "login %s vnc service with %s fail " %(ip,data)
                        self.lock.release()   
            except Exception,e:
                pass

    def run(self,ipdict,pinglist,threads,file):
        if len(ipdict['vnc']):
            printPink("crack vnc  now...")
            print "[*] start crack vnc  %s" % time.ctime()
            starttime=time.time()

            pool=Pool(threads)

            for ip in ipdict['vnc']:
                pool.apply_async(func=self.vnc_l,args=(str(ip).split(':')[0],int(str(ip).split(':')[1])))

            pool.close()
            pool.join()

            print "[*] stop vnc serice  %s" % time.ctime()
            print "[*] crack vnc done,it has Elapsed time:%s " % (time.time()-starttime)

            for i in xrange(len(self.result)):
                self.config.write_file(contents=self.result[i],file=file)    
                


