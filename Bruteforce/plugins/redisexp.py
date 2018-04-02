#coding=utf-8
import time
import threading
from threading import Thread
from printers import printPink,printGreen
from Queue import Queue
import redis

class redis_burp(object):
    
    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]
        #self.lines=self.config.file2list("conf/redis.conf")
        self.sp=Queue()

    def redisexp(self):
        while True:
            ip,port=self.sp.get()
            try:
                r=redis.Redis(host=ip,port=port,db=0,socket_timeout=8)
                r.dbsize()
                self.lock.acquire()
                printGreen('%s redis service at %s allow login Anonymous login!!\r\n' %(ip,port))
                self.result.append('%s redis service at %s allow login Anonymous login!!\r\n' %(ip,port))
                self.lock.release()
            except Exception,e:
                pass
            self.sp.task_done()



    def run(self,ipdict,pinglist,threads,file):
        if len(ipdict['redis']):
            printPink("crack redis  now...")
            print "[*] start crack redis  %s" % time.ctime()
            starttime=time.time()

            for i in xrange(threads):
                t = Thread(target=self.redisexp)
                t.setDaemon(True)
                t.start()

            for ip in ipdict['redis']:
                self.sp.put((str(ip).split(':')[0],int(str(ip).split(':')[1])))

            self.sp.join()


            print "[*] stop redis serice  %s" % time.ctime()
            print "[*] crack redis done,it has Elapsed time:%s " % (time.time()-starttime)

            for i in xrange(len(self.result)):
                self.config.write_file(contents=self.result[i],file=file)      

if __name__ == '__main__':
    import sys
    sys.path.append("../")
    from comm.config import *
    c=config()
    ipdict={'redis': ['101.201.177.35:6379']} 
    pinglist=['101.201.177.35']
    test=redis_burp(c)
    test.run(ipdict,pinglist,50,file="../result/test")

