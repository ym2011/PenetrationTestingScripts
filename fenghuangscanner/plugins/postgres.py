#coding=utf-8
import time
import threading
from printers import printPink,printGreen
from multiprocessing.dummy import Pool
import psycopg2
import re


def postgres_connect(ip,username,password,port):
    crack =0
    try:
        db=psycopg2.connect(user=username, password=password, host=ip, port=port)
        if db:
            crack=1
        db.close()
    except Exception, e:
        if re.findall(".*Password.*",e[0]):
            lock.acquire()
            print "%s postgres's %s:%s login fail" %(ip,username,password)
            lock.release()
            crack=2
        else:
            lock.acquire()
            print "connect %s postgres service at %s login fail " %(ip,port)
            lock.release()
            crack=3
        pass
    return crack

def postgreS(ip,port):
        try:
            d=open('conf/postgres.conf','r')
            data=d.readline().strip('\r\n')
            while(data):
                username=data.split(':')[0]
                password=data.split(':')[1]
                flag=postgres_connect(ip,username,password,port)
                time.sleep(0.1)
                if flag==3:
                    break

                if flag==1:
                    lock.acquire()
                    printGreen("%s postgres at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                    result.append("%s postgres at %s has weaken password!!-------%s:%s\r\n" %(ip,port,username,password))
                    lock.release()
                    break
                data=d.readline().strip('\r\n')
        except Exception,e:
            print e
            pass

def postgres_main(ipdict,threads):
    printPink("crack postgres now...")
    print "[*] start postgres  %s" % time.ctime()
    starttime=time.time()

    global lock
    lock = threading.Lock()
    global result
    result=[]

    pool=Pool(threads)

    for ip in ipdict['postgres']:
        pool.apply_async(func=postgreS,args=(str(ip).split(':')[0],int(str(ip).split(':')[1])))

    pool.close()
    pool.join()
    print "[*] stop crack postgres %s" % time.ctime()
    print "[*] crack postgres done,it has Elapsed time:%s " % (time.time()-starttime)
    return result