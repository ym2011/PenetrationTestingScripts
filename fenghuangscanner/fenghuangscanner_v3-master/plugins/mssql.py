#coding=utf-8
import time
import threading
from printers import printPink,printGreen
from multiprocessing.dummy import Pool
import pymssql



class mssql_burp(object):
    
    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]
        self.lines=self.config.file2list("conf/mssql.conf")

    def mssql_connect(self,ip,username,password,port):
        crack =0
        try:
            db=pymssql.connect(host=str(ip)+':'+str(port),user=username,password=password)
            if db:
                crack=1
            db.close()
        except Exception, e:
            self.lock.acquire()
            print "%s sql service 's %s:%s login fail " %(ip,username,password)
            self.lock.release()
        return crack


    def mssq1(self,ip,port):
            try:
                for data in self.lines:
                    username=data.split(':')[0]
                    password=data.split(':')[1]
                    flag=mssql_connect(ip,username,password,port)
                    if flag==2:
                        break
                    if flag==1:
                        self.lock.acquire()
                        printGreen("%s mssql at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.result.append("%s mssql at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.lock.release()
                        break
            except Exception,e:
                pass


    def run(self,ipdict,pinglist,threads,file):
        if len(ipdict['mysql']):
            printPink("crack sql serice  now...")
            print "[*] start crack sql serice  %s" % time.ctime()
            starttime=time.time()
            pool=Pool(threads)
            for ip in ipdict['mssql']:
                pool.apply_async(func=self.mssq1,args=(str(ip).split(':')[0],int(str(ip).split(':')[1])))
            pool.close()
            pool.join()

            print "[*] stop crack sql serice  %s" % time.ctime()
            print "[*] crack sql serice  done,it has Elapsed time:%s " % (time.time()-starttime)

            for i in xrange(len(self.result)):
                self.config.write_file(contents=self.result[i],file=file) 


