#!/usr/bin/python
# -*- coding: iso-8859-1 -*-
# -*- coding: utf-8 -*-
########################################################################################################
#
# crackhash.py - v0.01
#
# 国外在线破解hash的小脚本。  
# 
#####################################################################################################
try:
    import sys
    import hashlib
    import urllib2
    import getopt
    from os import path
    from urllib import urlencode
    from re import search, findall
    from random import seed, randint
    from base64 import decodestring, encodestring
    from cookielib import LWPCookieJar
except:
    print """
运行出错:

  以下的python 库尚未安装：
  
  该应用程序需要的库：sys, hashlib, urllib, urllib2, os, re, random, getopt, base64 and cookielib.
  
  请检查这些依赖库是否安装在您的操作系统上
  
  提示：安装这些库的格式为：
  
  apt-get install 库名字
  
  例如: apt-get install httplib2
  
  或者使用以下方式：
  
  easy_install httplib2
  
"""
    sys.exit(1)

try:
    from httplib2 import Http
except:
    print """
运行出错:

  Python 依赖库： httplib2  尚未被安装在您的系统中. 
  
  请在使用该程序之前安装该依赖库。 
  
"""
    sys.exit(1)

try:
    from libxml2 import parseDoc
except:
    print """
   
运行出错:

  Python 依赖库： libxml2 尚未被安装在您的系统中. 

  如果缺失该依赖库，部分插件将无法正常工作。
  
  请在使用该程序之前安装该依赖库。

"""

########################################################################################################
### 定义常量
########################################################################################################

MD4 = "md4"
MD5 = "md5"
SHA1 = "sha1"
SHA224 = "sha224"
SHA256 = "sha256"
SHA384 = "sha384"
SHA512 = "sha512"
RIPEMD = "rmd160"
LM = "lm"
NTLM = "ntlm"
MYSQL = "mysql"
CISCO7 = "cisco7"
JUNIPER = "juniper"
GOST = "gost"
WHIRLPOOL = "whirlpool"
LDAP_MD5 = "ldap_md5"
LDAP_SHA1 = "ldap_sha1"

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:2.0b8pre) Gecko/20101213 Firefox/4.0b8pre",
    "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)",
    "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 7.1; Trident/5.0)",
    "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0) chromeframe/10.0.648.205",
    "Opera/9.80 (Windows NT 6.1; U; sv) Presto/2.7.62 Version/11.01",
    "Opera/9.80 (Windows NT 6.1; U; pl) Presto/2.7.62 Version/11.00",
    "Opera/9.80 (X11; Linux i686; U; pl) Presto/2.6.30 Version/10.61",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.861.0 Safari/535.2",
    "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.872.0 Safari/535.2",
    "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.812.0 Safari/535.1",
]


########################################################################################################
### 定义破解网站
########################################################################################################


class NETMD5CRACK:
    name = "netmd5crack"
    url = "http://www.netmd5crack.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
		 # 如果成功破解，返回true，如果不能被破解，则返回false
        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://www.netmd5crack.com/cgi-bin/Crack.py?InputHash=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        regexp = r'<tr><td class="border">%s</td><td class="border">[^<]*</td></tr></table>' % (hashvalue)
        match = search(regexp, html)

        if match:
            match2 = search("Sorry, we don't have that hash in our database", match.group())
            if match2:
                return None
            else:
                return match.group().split('border')[2].split('<')[0][2:]


class BENRAMSEY:
    name = "benramsey"
    url = "http://tools.benramsey.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://tools.benramsey.com/md5/md5.php?hash=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<string><!\[CDATA\[[^\]]*\]\]></string>', html)

        if match:
            return match.group().split(']')[0][17:]
        else:
            return None


class GROMWEB:
    name = "gromweb"
    url = "http://md5.gromweb.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5.gromweb.com/query/%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        if response:
            return response.read()

        return response


class HASHCRACKING:
    name = "hashcracking"
    url = "http://md5.hashcracking.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5.hashcracking.com/search.php?md5=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'\sis.*', html)

        if match:
            return match.group()[4:]

        return None


class VICTOROV:
    name = "hashcracking"
    url = "http://victorov.su"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://victorov.su/md5/?md5e=&md5d=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r': <b>[^<]*</b><br><form action="">', html)

        if match:
            return match.group().split('b>')[1][:-2]

        return None


class THEKAINE:
    name = "thekaine"
    url = "http://md5.thekaine.de"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5.thekaine.de/?hash=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<td colspan="2"><br><br><b>[^<]*</b></td><td></td>', html)

        if match:

            match2 = search(r'not found', match.group())

            if match2:
                return None
            else:
                return match.group().split('b>')[1][:-2]


class TMTO:
    name = "tmto"
    url = "http://www.tmto.org"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://www.tmto.org/api/latest/?hash=%s&auth=true" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'text="[^"]+"', html)

        if match:
            return decodestring(match.group().split('"')[1])
        else:
            return None


class MD5_DB:
    name = "md5-db"
    url = "http://md5-db.de"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5-db.de/%s.html" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        if not response:
            return None

        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(
            r'<strong>Es wurden 1 m.gliche Begriffe gefunden, die den Hash \w* verwenden:</strong><ul><li>[^<]*</li>',
            html)

        if match:
            return match.group().split('li>')[1][:-2]
        else:
            return None


class MY_ADDR:
    name = "my-addr"
    url = "http://md5.my-addr.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5.my-addr.com/md5_decrypt-md5_cracker_online/md5_decoder_tool.php"

        # Build the parameters
        params = {"md5": hashvalue,
                  "x": 21,
                  "y": 8}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r"<span class='middle_title'>Hashed string</span>: [^<]*</div>", html)

        if match:
            return match.group().split('span')[2][3:-6]
        else:
            return None


class MD5PASS:
    name = "md5pass"
    url = "http://md5pass.info"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = self.url

        # Build the parameters
        params = {"hash": hashvalue,
                  "get_pass": "Get Pass"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r"Password - <b>[^<]*</b>", html)

        if match:
            return match.group().split('b>')[1][:-2]
        else:
            return None


class MD5DECRYPTION:
    name = "md5decryption"
    url = "http://md5decryption.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = self.url

        # Build the parameters
        params = {"hash": hashvalue,
                  "submit": "Decrypt It!"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r"Decrypted Text: </b>[^<]*</font>", html)

        if match:
            return match.group().split('b>')[1][:-7]
        else:
            return None


class MD5CRACK:
    name = "md5crack"
    url = "http://md5crack.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5crack.com/crackmd5.php"

        # Build the parameters
        params = {"term": hashvalue,
                  "crackbtn": "Crack that hash baby!"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'Found: md5\("[^"]+"\)', html)

        if match:
            return match.group().split('"')[1]
        else:
            return None


class MD5_DECRYPTER:
    name = "md5-decrypter"
    url = "http://md5-decrypter.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = self.url

        # Build the parameters
        params = {"data[Row][cripted]": hashvalue}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = findall(r'<b class="res">[^<]*</b>', html)

        if match:
            return match[1].split('>')[1][:-3]
        else:
            return None


class AUTHSECUMD5:
    name = "authsecu"
    url = "http://www.authsecu.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://www.authsecu.com/decrypter-dechiffrer-cracker-hash-md5/script-hash-md5.php"

        # Build the parameters
        params = {"valeur_bouton": "dechiffrage",
                  "champ1": "",
                  "champ2": hashvalue,
                  "dechiffrer.x": "78",
                  "dechiffrer.y": "7"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = findall(r'<td><p class="chapitre---texte-du-tableau-de-niveau-1">[^<]*</p></td>', html)

        if len(match) > 2:
            return match[1].split('>')[2][:-3]
        else:
            return None


class HASHCRACK:
    name = "hashcrack"
    url = "http://hashcrack.com"
    supported_algorithm = [MD5, SHA1, MYSQL, LM, NTLM]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://hashcrack.com/indx.php"

        hash2 = None
        if alg in [LM, NTLM] and ':' in hashvalue:
            if alg == LM:
                hash2 = hashvalue.split(':')[0]
            else:
                hash2 = hashvalue.split(':')[1]
        else:
            hash2 = hashvalue

        # Delete the possible starting '*'
        if alg == MYSQL and hash2[0] == '*':
            hash2 = hash2[1:]

        # Build the parameters
        params = {"auth": "8272hgt",
                  "hash": hash2,
                  "string": "",
                  "Submit": "Submit"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(
            r'<div align=center>"[^"]*" resolves to</div><br><div align=center> <span class=hervorheb2>[^<]*</span></div></TD>',
            html)

        if match:
            return match.group().split('hervorheb2>')[1][:-18]
        else:
            return None


class OPHCRACK:
    name = "ophcrack"
    url = "http://www.objectif-securite.ch"
    supported_algorithm = [LM, NTLM]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # Check if hashvalue has the character ':'
        if ':' not in hashvalue:
            return None

        # Ophcrack doesn't crack NTLM hashes. It needs a valid LM hash and this one is an empty hash.
        if hashvalue.split(':')[0] == "aad3b435b51404eeaad3b435b51404ee":
            return None

        # 创建查询URL and the headers
        url = "http://www.objectif-securite.ch/en/products.php?hash=%s" % (hashvalue.replace(':', '%3A'))

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(
            r'<table><tr><td>Hash:</td><td>[^<]*</td></tr><tr><td><b>Password:</b></td><td><b>[^<]*</b></td>', html)

        if match:
            return match.group().split('b>')[3][:-2]
        else:
            return None


class C0LLISION:
    name = "c0llision"
    url = "http://www.c0llision.net"
    supported_algorithm = [MD5, LM, NTLM]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # Check if hashvalue has the character ':'
        if alg in [LM, NTLM] and ':' not in hashvalue:
            return None

        # Look for "hash[_csrf_token]" parameter
        response = do_HTTP_request("http://www.c0llision.net/webcrack.php")
        html = None
        if response:
            html = response.read()
        else:
            return None
        match = search(r'<input type="hidden" name="hash._csrf_token." value="[^"]*" id="hash__csrf_token" />', html)
        token = None
        if match:
            token = match.group().split('"')[5]

        # 创建查询URL
        url = "http://www.c0llision.net/webcrack/request"

        # Build the parameters
        params = {"hash[_input_]": hashvalue,
                  "hash[_csrf_token]": token}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = None
        if alg in [LM, NTLM]:
            html = html.replace('\n', '')
            result = ""

            match = search(r'<table class="pre">.*?</table>', html)
            if match:
                try:
                    doc = parseDoc(match.group())
                except:
                    print "INFO: You need libxml2 to use this plugin."
                    return None
                lines = doc.xpathEval("//tr")
                for l in lines:
                    doc = parseDoc(str(l))
                    cols = doc.xpathEval("//td")

                    if len(cols) < 4:
                        return None

                    if cols[2].content:
                        result = " > %s (%s) = %s\n" % (cols[1].content, cols[2].content, cols[3].content)

                # return ( result and "\n" + result or None )
                return (result and result.split()[-1] or None)

        else:
            match = search(r'<td class="plaintext">[^<]*</td>', html)

            if match:
                return match.group().split('>')[1][:-4]

        return None


class REDNOIZE:
    name = "rednoize"
    url = "http://md5.rednoize.com"
    supported_algorithm = [MD5, SHA1]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = ""
        if alg == MD5:
            url = "http://md5.rednoize.com/?p&s=md5&q=%s&_=" % (hashvalue)
        else:
            url = "http://md5.rednoize.com/?p&s=sha1&q=%s&_=" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        return html


class CMD5:
    name = "cmd5"
    url = "http://www.cmd5.org"
    supported_algorithm = [MD5, NTLM]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # Look for hidden parameters
        response = do_HTTP_request("http://www.cmd5.org/")
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="[^"]*" />', html)
        viewstate = None
        if match:
            viewstate = match.group().split('"')[7]

        match = search(
            r'<input type="hidden" name="ctl00.ContentPlaceHolder1.HiddenField1" id="ctl00_ContentPlaceHolder1_HiddenField1" value="[^"]*" />',
            html)
        ContentPlaceHolder1 = ""
        if match:
            ContentPlaceHolder1 = match.group().split('"')[7]

        match = search(
            r'<input type="hidden" name="ctl00.ContentPlaceHolder1.HiddenField2" id="ctl00_ContentPlaceHolder1_HiddenField2" value="[^"]*" />',
            html)
        ContentPlaceHolder2 = ""
        if match:
            ContentPlaceHolder2 = match.group().split('"')[7]

        # 创建查询URL
        url = "http://www.cmd5.org/"

        hash2 = ""
        if alg == MD5:
            hash2 = hashvalue
        else:
            if ':' in hashvalue:
                hash2 = hashvalue.split(':')[1]

        # Build the parameters
        params = {"__EVENTTARGET": "",
                  "__EVENTARGUMENT": "",
                  "__VIEWSTATE": viewstate,
                  "ctl00$ContentPlaceHolder1$TextBoxq": hash2,
                  "ctl00$ContentPlaceHolder1$InputHashType": alg,
                  "ctl00$ContentPlaceHolder1$Button1": "decrypt",
                  "ctl00$ContentPlaceHolder1$HiddenField1": ContentPlaceHolder1,
                  "ctl00$ContentPlaceHolder1$HiddenField2": ContentPlaceHolder2}

        header = {"Referer": "http://www.cmd5.org/"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params, header)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<span id="ctl00_ContentPlaceHolder1_LabelResult">[^<]*</span>', html)

        if match:
            return match.group().split('>')[1][:-6]
        else:
            return None


class AUTHSECUCISCO7:
    name = "authsecu"
    url = "http://www.authsecu.com"
    supported_algorithm = [CISCO7]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL and the headers
        url = "http://www.authsecu.com/decrypter-dechiffrer-cracker-password-cisco-7/script-password-cisco-7-launcher.php"

        # Build the parameters
        params = {"valeur_bouton": "dechiffrage",
                  "champ1": hashvalue,
                  "dechiffrer.x": 43,
                  "dechiffrer.y": 16}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = findall(r'<td><p class="chapitre---texte-du-tableau-de-niveau-1">[^<]*</p></td>', html)

        if match:
            return match[1].split('>')[2][:-3]
        else:
            return None


class CACIN:
    name = "cacin"
    url = "http://cacin.net"
    supported_algorithm = [CISCO7]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL and the headers
        url = "http://cacin.net/cgi-bin/decrypt-cisco.pl?cisco_hash=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<tr>Cisco password 7: [^<]*</tr><br><tr><th><br>Decrypted password: .*', html)

        if match:
            return match.group().split(':')[2][1:]
        else:
            return None


class IBEAST:
    name = "ibeast"
    url = "http://www.ibeast.com"
    supported_algorithm = [CISCO7]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL and the headers
        url = "http://www.ibeast.com/content/tools/CiscoPassword/decrypt.php?txtPassword=%s&submit1=Enviar+consulta" % (
        hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<font size="\+2">Your Password is [^<]*<br>', html)

        if match:
            return match.group().split('is ')[1][:-4]
        else:
            return None


class PASSWORD_DECRYPT:
    name = "password-decrypt"
    url = "http://password-decrypt.com"
    supported_algorithm = [CISCO7, JUNIPER]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL and the parameters
        url = ""
        params = None
        if alg == CISCO7:
            url = "http://password-decrypt.com/cisco.cgi"
            params = {"submit": "Submit",
                      "cisco_password": hashvalue,
                      "submit": "Submit"}
        else:
            url = "http://password-decrypt.com/juniper.cgi"
            params = {"submit": "Submit",
                      "juniper_password": hashvalue,
                      "submit": "Submit"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'Decrypted Password:&nbsp;<B>[^<]*</B> </p>', html)

        if match:
            return match.group().split('B>')[1][:-2]
        else:
            return None


class HASHCHECKER:
    name = "hashchecker"
    url = "http://www.hashchecker.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL and the headers
        url = "http://www.hashchecker.com/index.php"

        # Build the parameters
        params = {"search_field": hashvalue,
                  "Submit": "search"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<td><li>Your md5 hash is :<br><li>[^\s]* is <b>[^<]*</b> used charlist :2</td>', html)

        if match:
            return match.group().split('b>')[1][:-2]
        else:
            return None


class MD5HASHCRACKER:
    name = "md5hashcracker"
    url = "http://md5hashcracker.appspot.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5hashcracker.appspot.com/crack"

        # Build the parameters
        params = {"query": hashvalue,
                  "submit": "Crack"}

        # Make the firt request
        response = do_HTTP_request(url, params)

        # Build the second URL
        url = "http://md5hashcracker.appspot.com/status"

        # Make the second request
        response = do_HTTP_request(url)

        # 分析响应
        if response:
            html = response.read()
        else:
            return None
        match = search(r'<td id="cra[^"]*">not cracked</td>', html)

        if not match:
            match = search(r'<td id="cra[^"]*">cracked</td>', html)
            regexp = r'<td id="pla_' + match.group().split('"')[1][4:] + '">[^<]*</td>'
            match2 = search(regexp, html)
            if match2:
                return match2.group().split('>')[1][:-4]

        else:
            return None


class PASSCRACKING:
    name = "passcracking"
    url = "http://passcracking.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://passcracking.com/index.php"

        # Build the parameters
        boundary = "-----------------------------" + str(
            randint(1000000000000000000000000000, 9999999999999999999999999999))
        params = ['--' + boundary,
                  'Content-Disposition: form-data; name="admin"',
                  '',
                  'false',

                  '--' + boundary,
                  'Content-Disposition: form-data; name="admin2"',
                  '',
                  '77.php',

                  '--' + boundary,
                  'Content-Disposition: form-data; name="datafromuser"',
                  '',
                  '%s' % (hashvalue),

                  '--' + boundary + '--', '']
        body = '\r\n'.join(params)

        # Build the headers
        headers = {"Content-Type": "multipart/form-data; boundary=%s" % (boundary),
                   "Content-length": len(body)}

        # 进行http 网络查询
        request = urllib2.Request(url)
        request.add_header("Content-Type", "multipart/form-data; boundary=%s" % (boundary))
        request.add_header("Content-length", len(body))
        request.add_data(body)
        try:
            response = urllib2.urlopen(request)
        except:
            return None

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<td>md5 Database</td><td>[^<]*</td><td bgcolor=.FF0000>[^<]*</td>', html)

        if match:
            return match.group().split('>')[5][:-4]
        else:
            return None


class ASKCHECK:
    name = "askcheck"
    url = "http://askcheck.com"
    supported_algorithm = [MD4, MD5, SHA1, SHA256]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://askcheck.com/reverse?reverse=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'Reverse value of [^\s]* hash <a[^<]*</a> is <a[^>]*>[^<]*</a>', html)

        if match:
            return match.group().split('>')[3][:-3]
        else:
            return None


class FOX21:
    name = "fox21"
    url = "http://cracker.fox21.at"
    supported_algorithm = [MD5, LM, NTLM]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        hash2 = None
        if alg in [LM, NTLM] and ':' in hashvalue:
            if alg == LM:
                hash2 = hashvalue.split(':')[0]
            else:
                hash2 = hashvalue.split(':')[1]
        else:
            hash2 = hashvalue

        # 创建查询URL
        url = "http://cracker.fox21.at/api.php?a=check&h=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        xml = None
        if response:
            try:
                doc = parseDoc(response.read())
            except:
                print "INFO: You need libxml2 to use this plugin."
                return None
        else:
            return None

        result = doc.xpathEval("//hash/@plaintext")

        if result:
            return result[0].content
        else:
            return None


class NICENAMECREW:
    name = "nicenamecrew"
    url = "http://crackfoo.nicenamecrew.com"
    supported_algorithm = [MD5, SHA1, LM]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        hash2 = None
        if alg in [LM] and ':' in hashvalue:
            hash2 = hashvalue.split(':')[0]
        else:
            hash2 = hashvalue

        # 创建查询URL
        url = "http://crackfoo.nicenamecrew.com/?t=%s" % (alg)

        # Build the parameters
        params = {"q": hash2,
                  "sa": "Crack"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'The decrypted version of [^\s]* is:<br><strong>[^<]*</strong>', html)

        if match:
            return match.group().split('strong>')[1][:-2].strip()
        else:
            return None


class JOOMLAAA:
    name = "joomlaaa"
    url = "http://joomlaaa.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://joomlaaa.com/component/option,com_md5/Itemid,31/"

        # Build the parameters
        params = {"md5": hashvalue,
                  "decode": "Submit"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r"<td class='title1'>not available</td>", html)

        if not match:
            match2 = findall(r"<td class='title1'>[^<]*</td>", html)
            return match2[1].split('>')[1][:-4]
        else:
            return None


class MD5_LOOKUP:
    name = "md5-lookup"
    url = "http://md5-lookup.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5-lookup.com/livesearch.php?q=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<td width="250">[^<]*</td>', html)

        if match:
            return match.group().split('>')[1][:-4]
        else:
            return None


class SHA1_LOOKUP:
    name = "sha1-lookup"
    url = "http://sha1-lookup.com"
    supported_algorithm = [SHA1]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://sha1-lookup.com/livesearch.php?q=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<td width="250">[^<]*</td>', html)

        if match:
            return match.group().split('>')[1][:-4]
        else:
            return None


class SHA256_LOOKUP:
    name = "sha256-lookup"
    url = "http://sha-256.sha1-lookup.com"
    supported_algorithm = [SHA256]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://sha-256.sha1-lookup.com/livesearch.php?q=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<td width="250">[^<]*</td>', html)

        if match:
            return match.group().split('>')[1][:-4]
        else:
            return None


class RIPEMD160_LOOKUP:
    name = "ripemd-lookup"
    url = "http://www.ripemd-lookup.com"
    supported_algorithm = [RIPEMD]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://www.ripemd-lookup.com/livesearch.php?q=%s" % (hashvalue)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<td width="250">[^<]*</td>', html)

        if match:
            return match.group().split('>')[1][:-4]
        else:
            return None


class MD5_COM_CN:
    name = "md5.com.cn"
    url = "http://md5.com.cn"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5.com.cn/md5reverse"

        # Build the parameters
        params = {"md": hashvalue,
                  "submit": "MD5 Crack"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<b style="color:red;">[^<]*</b><br/><span', html)

        if match:
            return match.group().split('>')[1][:-3]
        else:
            return None


class DIGITALSUN:
    name = "digitalsun.pl"
    url = "http://md5.digitalsun.pl"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5.digitalsun.pl/"

        # Build the parameters
        params = {"hash": hashvalue}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<b>[^<]*</b> == [^<]*<br>\s*<br>', html)

        if match:
            return match.group().split('b>')[1][:-2]
        else:
            return None


class MYINFOSEC:
    name = "myinfosec"
    url = "http://md5.myinfosec.net"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5.myinfosec.net/md5.php"

        # Build the parameters
        params = {"md5hash": hashvalue}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<center></center>[^<]*<font color=green>[^<]*</font><br></center>', html)

        if match:
            return match.group().split('>')[3][:-6]
        else:
            return None


class MD5_NET:
    name = "md5.net"
    url = "http://md5.net"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://www.md5.net/cracker.php"

        # Build the parameters
        params = {"hash": hashvalue}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<input type="text" id="hash" size="32" value="[^"]*"/>', html)

        if match:
            return match.group().split('"')[7]
        else:
            return None


class NOISETTE:
    name = "noisette.ch"
    url = "http://md5.noisette.ch"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5.noisette.ch/index.php"

        # Build the parameters
        params = {"hash": hashvalue}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<p>String to hash : <input name="text" value="[^"]+"/>', html)

        if match:
            return match.group().split('"')[3]
        else:
            return None


class MD5HOOD:
    name = "md5hood"
    url = "http://md5hood.com"
    supported_algorithm = [MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://md5hood.com/index.php/cracker/crack"

        # Build the parameters
        params = {"md5": hashvalue,
                  "submit": "Go"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<div class="result_true">[^<]*</div>', html)

        if match:
            return match.group().split('>')[1][:-5]
        else:
            return None


class XANADREL:
    name = "99k.org"
    url = "http://xanadrel.99k.org"
    supported_algorithm = [MD4, MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://xanadrel.99k.org/hashes/index.php?k=search"

        # Build the parameters
        params = {"hash": hashvalue,
                  "search": "ok"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<p>Hash : [^<]*<br />Type : [^<]*<br />Plain : "[^"]*"<br />', html)

        if match:
            return match.group().split('"')[1]
        else:
            return None


class SANS:
    name = "sans"
    url = "http://isc.sans.edu"
    supported_algorithm = [MD5, SHA1]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://isc.sans.edu/tools/reversehash.html"

        # Build the Headers with a random User-Agent
        headers = {"User-Agent": USER_AGENTS[randint(0, len(USER_AGENTS)) - 1]}

        # Build the parameters
        response = do_HTTP_request(url, httpheaders=headers)
        html = None
        if response:
            html = response.read()
        else:
            return None
        match = search(r'<input type="hidden" name="token" value="[^"]*" />', html)
        token = ""
        if match:
            token = match.group().split('"')[5]
        else:
            return None

        params = {"token": token,
                  "text": hashvalue,
                  "word": "",
                  "submit": "Submit"}

        # Build the Headers with the Referer header
        headers["Referer"] = "http://isc.sans.edu/tools/reversehash.html"

        # 进行http 网络查询
        response = do_HTTP_request(url, params, headers)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'... hash [^\s]* = [^\s]*\s*</p><br />', html)

        if match:
            print "hola mundo"
            return match.group().split('=')[1][:-10].strip()
        else:
            return None


class BOKEHMAN:
    name = "bokehman"
    url = "http://bokehman.com"
    supported_algorithm = [MD4, MD5]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        # 创建查询URL
        url = "http://bokehman.com/cracker/"

        # Build the parameters from the main page
        response = do_HTTP_request(url)
        html = None
        if response:
            html = response.read()
        else:
            return None
        match = search(r'<input type="hidden" name="PHPSESSID" id="PHPSESSID" value="[^"]*" />', html)
        phpsessnid = ""
        if match:
            phpsessnid = match.group().split('"')[7]
        else:
            return None
        match = search(r'<input type="hidden" name="key" id="key" value="[^"]*" />', html)
        key = ""
        if match:
            key = match.group().split('"')[7]
        else:
            return None

        params = {"md5": hashvalue,
                  "PHPSESSID": phpsessnid,
                  "key": key,
                  "crack": "Try to crack it"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<tr><td>[^<]*</td><td>[^<]*</td><td>[^s]*seconds</td></tr>', html)

        if match:
            return match.group().split('td>')[1][:-2]
        else:
            return None


class GOOG_LI:
    name = "goog.li"
    url = "http://goog.li"
    supported_algorithm = [MD5, MYSQL, SHA1, SHA224, SHA384, SHA256, SHA512, RIPEMD, NTLM, GOST, WHIRLPOOL, LDAP_MD5,
                           LDAP_SHA1]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        hash2 = None
        if alg in [NTLM] and ':' in hashvalue:
            hash2 = hashvalue.split(':')[1]
        else:
            hash2 = hashvalue

        # Confirm the initial '*' character
        if alg == MYSQL and hash2[0] != '*':
            hash2 = '*' + hash2

        # 创建查询URL
        url = "http://goog.li/?q=%s" % (hash2)

        # 进行http 网络查询
        response = do_HTTP_request(url)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<br />cleartext[^:]*: [^<]*<br />', html)

        if match:
            return match.group().split(':')[1].strip()[:-6]
        else:
            return None


class WHREPORITORY:
    name = "Windows Hashes Repository"
    url = "http://nediam.com.mx"
    supported_algorithm = [LM, NTLM]

    def isSupported(self, alg):
        """Return True if HASHCRACK can crack this type of algorithm and
		False if it cannot."""

        if alg in self.supported_algorithm:
            return True
        else:
            return False

    def crack(self, hashvalue, alg):
        """Try to crack the hash.
		@param hashvalue Hash to crack.
		@param alg Algorithm to crack."""

        # 检查是否支持该种算法
        if not self.isSupported(alg):
            return None

        hash2 = None
        if ':' in hashvalue:
            if alg == LM:
                hash2 = hashvalue.split(':')[0]
            else:
                hash2 = hashvalue.split(':')[1]
        else:
            hash2 = hashvalue

        # 创建查询URL, parameters and headers
        url = ""
        params = None
        headers = None
        if alg == LM:
            url = "http://nediam.com.mx/winhashes/search_lm_hash.php"
            params = {"lm": hash2,
                      "btn_go": "Search"}
            headers = {"Referer": "http://nediam.com.mx/winhashes/search_lm_hash.php"}
        else:
            url = "http://nediam.com.mx/winhashes/search_nt_hash.php"
            params = {"nt": hash2,
                      "btn_go": "Search"}
            headers = {"Referer": "http://nediam.com.mx/winhashes/search_nt_hash.php"}

        # 进行http 网络查询
        response = do_HTTP_request(url, params, headers)

        # 分析响应
        html = None
        if response:
            html = response.read()
        else:
            return None

        match = search(r'<tr><td align="right">PASSWORD</td><td>[^<]*</td></tr>', html)

        if match:
            return match.group().split(':')[1]
        else:
            return None


CRAKERS = [
		NETMD5CRACK,
		BENRAMSEY,
		GROMWEB,
		HASHCRACKING,
		VICTOROV,
		THEKAINE,
		TMTO,
		REDNOIZE,
		MD5_DB,
		MY_ADDR,
		MD5PASS,
		MD5DECRYPTION,
		MD5CRACK,
		MD5_DECRYPTER,
		AUTHSECUMD5,
		HASHCRACK,
		OPHCRACK,
		C0LLISION,
		CMD5,
		AUTHSECUCISCO7,
		CACIN,
		IBEAST,
		PASSWORD_DECRYPT,
		HASHCHECKER,
		MD5HASHCRACKER,
		PASSCRACKING,
		ASKCHECK,
		FOX21,
		NICENAMECREW,
		JOOMLAAA,
		MD5_LOOKUP,
		SHA1_LOOKUP,
		SHA256_LOOKUP,
		RIPEMD160_LOOKUP,
		MD5_COM_CN,
		DIGITALSUN,
		MYINFOSEC,
		MD5_NET,
		NOISETTE,
		MD5HOOD,
		XANADREL,
		SANS,
		BOKEHMAN,
		GOOG_LI,
		WHREPORITORY ]



########################################################################################################
### GENERAL METHODS
########################################################################################################

def configureCookieProcessor (cookiefile='/tmp/searchmyhash.cookie'):
	'''Set a Cookie Handler to accept cookies from the different Web sites.
	
	@param cookiefile Path of the cookie store.'''
	
	cookieHandler = LWPCookieJar()
	if cookieHandler is not None:
		if path.isfile (cookiefile):
			cookieHandler.load (cookiefile)
			
		opener = urllib2.build_opener ( urllib2.HTTPCookieProcessor(cookieHandler) )
		urllib2.install_opener (opener)



def do_HTTP_request (url, params={}, httpheaders={}):
	'''
	Send a GET or POST HTTP Request.
	@return: HTTP Response
	'''

	data = {}
	request = None
	
	# If there is parameters, they are been encoded
	if params:
		data = urlencode(params)

		request = urllib2.Request ( url, data, headers=httpheaders )
	else:
		request = urllib2.Request ( url, headers=httpheaders )
		
	# Send the request
	try:
		response = urllib2.urlopen (request)
	except:
		return ""
	
	return response


def printSyntax ():
	"""Print application syntax."""
	
	print """%s 0.1 ( https://github.com/ym2011/penetration )

Usage: 
------

  python %s <加密算法> 选项


目前支持的算法是:
--------------------------------------------

  MD4       - RFC 1320
  MD5       - RFC 1321
  SHA1      - RFC 3174 (FIPS 180-3)
  SHA224    - RFC 3874 (FIPS 180-3)
  SHA256    - FIPS 180-3
  SHA384    - FIPS 180-3
  SHA512    - FIPS 180-3
  RMD160    - RFC 2857
  GOST      - RFC 5831
  WHIRLPOOL - ISO/IEC 10118-3:2004
  LM        - Microsoft Windows hash
  NTLM      - Microsoft Windows hash
  MYSQL     - MySQL 3, 4, 5 hash
  CISCO7    - Cisco IOS type 7 encrypted passwords
  JUNIPER   - Juniper Networks $9$ encrypted passwords
  LDAP_MD5  - MD5 Base64 encoded
  LDAP_SHA1 - SHA1 Base64 encoded
 
  NOTE: for LM / NTLM it is recommended to introduce both values with this format:
         python %s LM   -h 9a5760252b7455deaad3b435b51404ee:0d7f1f2bdeac6e574d6e18ca85fb58a7
         python %s NTLM -h 9a5760252b7455deaad3b435b51404ee:0d7f1f2bdeac6e574d6e18ca85fb58a7


Valid OPTIONS are:
------------------

  -h <hash_value>  If you only want to crack one hash, specify its value with this option.

  -f <file>        If you have several hashes, you can specify a file with one hash per line.
                   NOTE: All of them have to be the same type.
                   
  -g               If your hash cannot be cracked, search it in Google and show all the results.
                   NOTE: This option ONLY works with -h (one hash input) option.


Examples:
---------

  -> Try to crack only one hash.
     python %s MD5 -h 098f6bcd4621d373cade4e832627b4f6
     
  -> Try to crack a JUNIPER encrypted password escaping special characters.
     python %s JUNIPER -h "\$9\$LbHX-wg4Z"
  
  -> If the hash cannot be cracked, it will be searched in Google.
     python %s LDAP_SHA1 -h "{SHA}cRDtpNCeBiql5KOQsKVyrA0sAiA=" -g
   
  -> Try to crack multiple hashes using a file (one hash per line).
     python %s MYSQL -f mysqlhashesfile.txt
     

source:
-----------------------------------
https://github.com/ym2011/penetration

""" % ( (sys.argv[0],) * 8 )



def crackHash (algorithm, hashvalue=None, hashfile=None):
	"""Crack a hash or all the hashes of a file.
	
	@param alg Algorithm of the hash (MD5, SHA1...).
	@param hashvalue Hash value to be cracked.
	@param hashfile Path of the hash file.
	@return If the hash has been cracked or not."""
	
	global CRAKERS
	
	# Cracked hashes will be stored here
	crackedhashes = []
	
	# Is the hash cracked?
	cracked = False
	
	# Only one of the two possible inputs can be setted.
	if (not hashvalue and not hashfile) or (hashvalue and hashfile):
		return False
	
	# hashestocrack depends on the input value
	hashestocrack = None
	if hashvalue:
		hashestocrack = [ hashvalue ]
	else:
		try:
			hashestocrack = open (hashfile, "r")
		except:
			print "\nIt is not possible to read input file (%s)\n" % (hashfile)
			return cracked
	
	
	# Try to crack all the hashes...
	for activehash in hashestocrack:
		hashresults = []
		
		# Standarize the hash
		activehash = activehash.strip()
		if algorithm not in [JUNIPER, LDAP_MD5, LDAP_SHA1]:
			activehash = activehash.lower()
		
		# Initial message
		print "\nCracking hash: %s\n" % (activehash)

		# Each loop starts for a different start point to try to avoid IP filtered
		begin = randint(0, len(CRAKERS ) -1)
		
		for i in range(len(CRAKERS)):
			
			# Select the cracker
			cr = CRAKERS[ ( i +begin ) %len(CRAKERS) ]()
			
			# Check if the cracker support the algorithm
			if not cr.isSupported ( algorithm ):
				continue
			
			# Analyze the hash
			print "Analyzing with %s (%s)..." % (cr.name, cr.url)
			
			# Crack the hash
			result = None
			try:
				result = cr.crack ( activehash, algorithm )
			# If it was some trouble, exit
			except:
				print "\nSomething was wrong. Please, contact with us to report the bug:\n\nbloglaxmarcaellugar@gmail.com\n"
				if hashfile:
					try:
						hashestocrack.close()
					except:
						pass
				return False
			
			# If there is any result...
			cracked = 0
			if result:
				
				# If it is a hashlib supported algorithm...
				if algorithm in [MD4, MD5, SHA1,  SHA224, SHA384, SHA256, SHA512, RIPEMD]:
					# Hash value is calculated to compare with cracker result
					h = hashlib.new (algorithm)
					h.update (result)
					
					# If the calculated hash is the same to cracker result, the result is correct (finish!)
					if h.hexdigest() == activehash:
						hashresults.append (result)
						cracked = 2
				
				# If it is a half-supported hashlib algorithm
				elif algorithm in [LDAP_MD5, LDAP_SHA1]:
					alg = algorithm.split('_')[1]
					ahash =  decodestring ( activehash.split('}')[1] )
					
					# Hash value is calculated to compare with cracker result
					h = hashlib.new (alg)
					h.update (result)
					
					# If the calculated hash is the same to cracker result, the result is correct (finish!)
					if h.digest() == ahash:
						hashresults.append (result)
						cracked = 2
				
				# If it is a NTLM hash
				elif algorithm == NTLM or (algorithm == LM and ':' in activehash):
					# NTLM Hash value is calculated to compare with cracker result
					candidate = hashlib.new('md4', result.split()[-1].encode('utf-16le')).hexdigest()
					
					# It's a LM:NTLM combination or a single NTLM hash
					if (':' in activehash and candidate == activehash.split(':')[1]) or \
                            (':' not in activehash and candidate == activehash):
                        hashresults.append(result)
                        cracked = 2

                # If it is another algorithm, we search in all the crackers
                else:
                    hashresults.append(result)
                    cracked = 1

            # Had the hash cracked?
            if cracked:
                print "\n***** HASH CRACKED!! *****\nThe original string is: %s\n" % (result)
                # If result was verified, break
                if cracked == 2:
                    break
            else:
                print "... hash not found in %s\n" % (cr.name)

        # Store the result/s for later...
        if hashresults:

            # With some hash types, it is possible to have more than one result,
            # Repited results are deleted and a single string is constructed.
            resultlist = []
            for r in hashresults:
                # if r.split()[-1] not in resultlist:
                # resultlist.append (r.split()[-1])
                if r not in resultlist:
                    resultlist.append(r)

            finalresult = ""
            if len(resultlist) > 1:
                finalresult = ', '.join(resultlist)
            else:
                finalresult = resultlist[0]

            # Valid results are stored
            crackedhashes.append((activehash, finalresult))

    # Loop is finished. File can need to be closed
    if hashfile:
        try:
            hashestocrack.close()
        except:
            pass

    # Show a resume of all the cracked hashes
    print "\nThe following hashes were cracked:\n----------------------------------\n"
    print crackedhashes and "\n".join(
            "%s -> %s" % (hashvalue, result.strip()) for hashvalue, result in crackedhashes) or "NO HASH WAS CRACKED."
    print

    return cracked


def searchHash(hashvalue):
    '''Google the hash value looking for any result which could give some clue...
	
	@param hashvalue The hash is been looking for.'''

    start = 0
    finished = False
    results = []

    sys.stdout.write("\nThe hash wasn't found in any database. Maybe Google has any idea...\nLooking for results...")
    sys.stdout.flush()

    while not finished:

        sys.stdout.write('.')
        sys.stdout.flush()

        # 创建查询URL
        url = "http://www.google.com/search?hl=en&q=%s&filter=0" % (hashvalue)
        if start:
            url += "&start=%d" % (start)

        # Build the Headers with a random User-Agent
        headers = {"User-Agent": USER_AGENTS[randint(0, len(USER_AGENTS)) - 1]}

        # Send the request
        response = do_HTTP_request(url, httpheaders=headers)

        # Extract the results ...
        html = None
        if response:
            html = response.read()
        else:
            continue

        resultlist = findall(r'<a href="[^"]*?" class=l', html)

        # ... saving only new ones
        new = False
        for r in resultlist:
            url_r = r.split('"')[1]

            if not url_r in results:
                results.append(url_r)
                new = True

        start += len(resultlist)

        # If there is no a new result, finish
        if not new:
            finished = True

    # Show the results
    if results:
        print "\n\nGoogle has some results. Maybe you would like to check them manually:\n"

        results.sort()
        for r in results:
            print "  *> %s" % (r)
        print

    else:
        print "\n\nGoogle doesn't have any result. Sorry!\n"


########################################################################################################
### MAIN CODE
########################################################################################################

def main():
    """Main method."""

    ###################################################
    # Syntax check
    if len(sys.argv) < 4:
        printSyntax()
        sys.exit(1)

    else:
        try:
            opts, args = getopt.getopt(sys.argv[2:], "gh:f:")
        except:
            printSyntax()
            sys.exit(1)

    ###################################################
    # Load input parameters
    algorithm = sys.argv[1].lower()
    hashvalue = None
    hashfile = None
    googlesearch = False

    for opt, arg in opts:
        if opt == '-h':
            hashvalue = arg
        elif opt == '-f':
            hashfile = arg
        else:
            googlesearch = True

    ###################################################
    # Configure the Cookie Handler
    configureCookieProcessor()

    # Initialize PRNG seed
    seed()

    cracked = 0

    ###################################################
    # Crack the hash/es
    cracked = crackHash(algorithm, hashvalue, hashfile)

    ###################################################
    # Look for the hash in Google if it was not cracked
    if not cracked and googlesearch and not hashfile:
        searchHash(hashvalue)

    # App is finished
    sys.exit()


if __name__ == "__main__":
    main()
