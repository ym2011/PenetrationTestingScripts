#coding=utf-8
import time
from printers import printPink,printGreen
import threading
from multiprocessing.dummy import Pool
import poplib

def pop3_Connection(ip,username,password,port):
    try:
        pp = poplib.POP3(ip)
        #pp.set_debuglevel(1)
        pp.user(username)
        pp.pass_(password)
        (mailCount,size) = pp.stat()
        pp.quit()
        if mailCount:
            lock.acquire()
            printGreen("%s pop3 at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
            result.append("%s pop3 at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
            lock.release()
    except Exception,e:
        print e
        lock.acquire()
        print "%s pop3 service 's %s:%s login fail " %(ip,username,password)
        lock.release()
        pass

def pop3_l(ip,port):
        try:
            d=open('conf/pop3.conf','r')
            data=d.readline().strip('\r\n')
            while(data):
                username=data.split(':')[0]
                password=data.split(':')[1]
                pop3_Connection(ip,username,password,port)
                data=d.readline().strip('\r\n')
        except Exception,e:
            print e
            pass

def pop_main(ipdict,threads):
    printPink("crack pop  now...")
    print "[*] start crack pop  %s" % time.ctime()
    starttime=time.time()

    global lock
    lock = threading.Lock()
    global result
    result=[]

    pool=Pool(threads)

    for ip in ipdict['pop3']:
        pool.apply_async(func=pop3_l,args=(str(ip).split(':')[0],int(str(ip).split(':')[1])))

    pool.close()
    pool.join()

    print "[*] stop pop serice  %s" % time.ctime()
    print "[*] crack pop done,it has Elapsed time:%s " % (time.time()-starttime)
    return result