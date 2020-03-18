#coding=utf-8
import time
import threading
from printers import printPink,printGreen
from multiprocessing.dummy import Pool
import MySQLdb


class mysql_burp(object):
    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]
        self.lines=self.config.file2list("conf/mysql.conf")

    def mysql_connect(self,ip,username,password,port):
        crack =0
        try:
            db=MySQLdb.connect(ip,username,password,port=port)
            if db:
                crack=1
            db.close()
        except Exception, e:
            if e[0]==1045:
                self.lock.acquire()
                print "%s mysql's %s:%s login fail" %(ip,username,password)
                self.lock.release()
            else:
                self.lock.acquire()
                print "connect %s mysql service at %s login fail " %(ip,port)
                self.lock.release()
                crack=2
        return crack

    def mysq1(self,ip,port):
            try:
                for data in self.lines:
                    username=data.split(':')[0]
                    password=data.split(':')[1]
                    flag=self.mysql_connect(ip,username,password,port)
                    if flag==2:
                        break

                    if flag==1:
                        self.lock.acquire()
                        printGreen("%s mysql at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.result.append("%s mysql at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.lock.release()
                        break
            except Exception,e:
                pass

    def run(self,ipdict,pinglist,threads,file):
        if len(ipdict['mysql']):
            printPink("crack mysql now...")
            print "[*] start crack mysql %s" % time.ctime()
            starttime=time.time()

            pool=Pool(threads)
            for ip in ipdict['mysql']:
                pool.apply_async(func=self.mysq1,args=(str(ip).split(':')[0],int(str(ip).split(':')[1])))

            pool.close()
            pool.join()

            print "[*] stop crack mysql %s" % time.ctime()
            print "[*] crack mysql done,it has Elapsed time:%s " % (time.time()-starttime)

            for i in xrange(len(self.result)):
                self.config.write_file(contents=self.result[i],file=file) 

if __name__ == '__main__':
    import sys
    sys.path.append("../")
    from comm.config import *
    c=config()
    ipdict={'mysql': ['127.0.0.1:3306']} 
    pinglist=['127.0.0.1']
    test=mysql_burp(c)
    test.run(ipdict,pinglist,50,file="../result/test")