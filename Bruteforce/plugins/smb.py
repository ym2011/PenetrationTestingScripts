#coding=utf-8
import time
import threading
from printers import printPink,printGreen
from impacket.smbconnection import *
from multiprocessing.dummy import Pool
from threading import Thread


class smb_burp(object):
    
    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]
        self.lines=self.config.file2list("conf/smb.conf")

    def smb_connect(self,ip,username,password):
        crack =0
        try:
            smb = SMBConnection('*SMBSERVER', ip)
            smb.login(username,password)
            smb.logoff()
            crack =1
        except Exception, e:
            self.lock.acquire()
            print "%s smb 's %s:%s login fail " %(ip,username,password)
            self.lock.release()
        return crack

    def smb_l(self,ip,port):
            try:
                for data in self.lines:
                    username=data.split(':')[0]
                    password=data.split(':')[1]
                    if self.smb_connect(ip,username,password)==1:
                        self.lock.acquire()
                        printGreen("%s smb at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.result.append("%s smb at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.lock.release()
                        break
            except Exception,e:
                pass

    def run(self,ipdict,pinglist,threads,file):
        if len(ipdict['smb']):
            printPink("crack smb  now...")
            print "[*] start crack smb serice  %s" % time.ctime()
            starttime=time.time()

            pool=Pool(threads)

            for ip in ipdict['smb']:
                pool.apply_async(func=self.smb_l,args=(str(ip).split(':')[0],int(str(ip).split(':')[1])))

            pool.close()
            pool.join()

            print "[*] stop smb serice  %s" % time.ctime()
            print "[*] crack smb  done,it has Elapsed time:%s " % (time.time()-starttime)

            for i in xrange(len(self.result)):
                self.config.write_file(contents=self.result[i],file=file) 
if __name__ == '__main__':
    import sys
    sys.path.append("../")
    from comm.config import *
    c=config()
    ipdict={'smb': ['10.211.55.3:445']} 
    pinglist=['101.201.177.35']
    test=smb_burp(c)
    test.run(ipdict,pinglist,50,file="../result/test")