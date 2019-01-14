# -*- coding: utf-8 -*-

import configparser
import os
import re
import smtplib
import sqlite3
import sys
import traceback
from email import encoders
from email.header import Header
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import formataddr, parseaddr
from time import gmtime, sleep, strftime

import requests
from lxml import etree
from lxml.html import tostring
from tqdm import tqdm


'''
工具名:GithubHunter
作者：Allen_Zhang
主要用途：本工具主要是查询Github中可能泄露的代码，用户名，密码，数据库信息，网络结构信息等
实现方法：通过登陆Github后，搜索关键词，然后呈现数据
'''

def login_github(username,password):#登陆Github
    #初始化参数
    login_url = 'https://github.com/login'
    session_url = 'https://github.com/session'
    try:
        #获取session
        s = requests.session()
        resp = s.get(login_url).text
        dom_tree = etree.HTML(resp)
        key = dom_tree.xpath('//input[@name="authenticity_token"]/@value')
        user_data = {
            'commit': 'Sign in',
            'utf8': '✓',
            'authenticity_token': key,
            'login': username,
            'password': password
        }
        #发送数据并登陆
        s.post(session_url,data=user_data)
        s.get('https://github.com/settings/profile')
        return s
    except Exception as e:
        print('产生异常，请检查网络设置及用户名和密码')
        error_Record(str(e), traceback.format_exc())

def hunter(gUser, gPass, keywords):#根据关键词获取想要查询的内容

    print('''\033[1;34;0m     #####                                  #     #                                   
    #     # # ##### #    # #    # #####     #     # #    # #    # ##### ###### #####  
    #       #   #   #    # #    # #    #    #     # #    # ##   #   #   #      #    # 
    #  #### #   #   ###### #    # #####     ####### #    # # #  #   #   #####  #    # 
    #     # #   #   #    # #    # #    #    #     # #    # #  # #   #   #      #####  
    #     # #   #   #    # #    # #    #    #     # #    # #   ##   #   #      #   #  
     #####  #   #   #    #  ####  #####     #     #  ####  #    #   #   ###### #    #    V1.2 
                                                                                         Created by Allen   \r\n\r\n\033[0m''')

    global codes
    global tUrls
    try:
        #代码搜索
        s = login_github(gUser,gPass)
        print('登陆成功，正在检索泄露信息.......')
        sleep(1)
        codes = []
        tUrls = []
        #新加入2条正则匹配，第一条匹配搜索出来的代码部分；第二条则进行高亮显示关键词
        pattern_code = re.compile(r'<div class="file-box blob-wrapper">(.*?)</div>', re.S)
        pattern_sub = re.compile(r'<em>', re.S)
        for keyword in keywords:
            for page in tqdm(range(1,7)):
                #更改搜索排序方式的url，收录可能存在泄漏的url还是使用xpath解析
                search_code = 'https://github.com/search?o=desc&p=' + str(page) + '&q=' + keyword +'&s=indexed&type=Code'
                resp = s.get(search_code)
                results_code = resp.text
                dom_tree_code = etree.HTML(results_code)
                #获取存在信息泄露的链接地址
                Urls = dom_tree_code.xpath('//div[@class="flex-auto min-width-0 col-10"]/a[2]/@href')
                for url in Urls:
                    url = 'https://github.com' + url
                    tUrls.append(url)
                #获取代码部分，先获得整个包含泄露代码的最上层DIV对象，再把对象进行字符化，便于使用正则进行匹配泄露代码部分的div
                results = dom_tree_code.xpath('//div[@class="code-list-item col-12 py-4 code-list-item-public "]')
                for div in results:
                    result = etree.tostring(div, pretty_print=True, method="html")
                    code = str(result, encoding='utf-8')
                    #如果存在<div class="file-box blob-wrapper">此标签则匹配泄露的关键代码部分，不存在则为空。
                    if '<div class="file-box blob-wrapper">' in code:
                        data = pattern_code.findall(code)
                        codes.append(pattern_sub.sub('<em style="color:red">', data[0]))
                    else:
                        codes.append(' ')

        return tUrls, codes

    except Exception as e:
        #如发生错误，则写入文件并且打印出来
        error_Record(str(e), traceback.format_exc())
        print(e)

def insert_DB(url, code):
    try:
        conn = sqlite3.connect('hunter.db')
        cursor = conn.cursor()
        cursor.execute('CREATE TABLE IF NOT EXISTS Baseline (url varchar(1000) primary key, code varchar(10000))')
        cursor.execute('INSERT OR REPLACE INTO Baseline (url, code) values (?,?)', (url, code))
        cursor.close
        conn.commit()
        conn.close()
    except Exception as e:
        print("数据库操作失败！\n")
        error_Record(str(e), traceback.format_exc())
        print(e)

def compare_DB_Url(url):
    try:
        con = sqlite3.connect('hunter.db')
        cur = con.cursor()
        cur.execute('SELECT url from Baseline where url = ?', (url,))
        results = cur.fetchall()
        cur.close()
        con.commit()
        con.close()
        return results
    except Exception as e:
        error_Record(str(e), traceback.format_exc())
        print(e)

def error_Record(error, tb):
    try:
        if os.path.exists('error.txt'):
            with open('error.txt', 'a', encoding='utf-8') as f:
                f.write(strftime("%a, %d %b %Y %H:%M:%S",gmtime()) + "-" + "Exception Record: " + error + '\n' + "具体错误信息如下：\n" +tb + '\r\n')
        else:
            with open('error.txt', 'w', encoding='utf-8') as f:
                f.write(strftime("%a, %d %b %Y %H:%M:%S",gmtime()) + "-" + "Exception Record: " + error + '\n' + "具体错误信息如下：\n" +tb + '\r\n')
    except Exception as e:
        print(e)

def send_mail(host, username, password, sender, receivers, message): 
    def _format_addr(s):
        name,addr = parseaddr(s)
        return formataddr((Header(name,'utf-8').encode(),addr))

    msg = MIMEText(message, 'html', 'utf-8')
    subject = 'Github信息泄露监控通知'
    msg['Subject'] = Header(subject, 'utf-8').encode()
    msg['From'] = _format_addr('Github信息泄露监控<%s>' % sender)
    msg['To'] = ','.join(receivers)
    try:
        smtp_obj = smtplib.SMTP(host, 25)
        smtp_obj.login(username, password)
        smtp_obj.sendmail(sender, receivers, msg.as_string())
        print('邮件发送成功！')
        smtp_obj.close()
    except Exception as err:
        error_Record(str(err), traceback.format_exc())
        print(err)

if __name__ == '__main__':
    config = configparser.ConfigParser()
    config.read('info.ini')
    g_User = config['Github']['user']
    g_Pass = config['Github']['password']
    host = config['EMAIL']['host']
    m_User = config['EMAIL']['user']
    m_Pass = config['EMAIL']['password']
    m_sender = config['SENDER']['sender']
    receivers = []
    for k in config['RECEIVER']:
        receivers.append(config['RECEIVER'][k])
    keywords = []
    #组合关键词，keyword + payload,两者之间加入“+”号，符合Github搜索语法
    for keyword in config['KEYWORD']:
        for payload in config['PAYLOADS']:
            keywords.append(config['KEYWORD'][keyword] + '+' + config['PAYLOADS'][payload])

    message = 'Dear all<br><br>未发现任何新增敏感信息！'
    tUrls, codes= hunter(g_User, g_Pass, keywords)
    target_codes = []
    #第一次运行会查找是否存在数据文件，如果不存在则新建，存在则进行新增条目查找
    if os.path.exists('hunter.db'):
        print("存在数据库文件，进行新增数据查找......")
        #拆分关键词，在泄露的代码中查找关键词和payload.如果两者都存在则进行下一步数据库查找
        for keyword in keywords:
            payload = keyword.split('+')
            for i in range(0, len(tUrls)):
                if (payload[0] in codes[i]) and (payload[1] in codes[i]):
                    #如果数据库中返回的值为空，则说明该条目在数据库中不存在，那么添加到target_codes里面用户发送邮件，并且添加到数据库中
                    if not compare_DB_Url(tUrls[i]):
                        target_codes.append('<br><br><br>' + '链接：' + tUrls[i] + '<br><br>')
                        target_codes.append('简要代码如下：<br><div style="border:1px solid #bfd1eb;background:#f3faff">' + codes[i] + '</div>')
                        insert_DB(tUrls[i], codes[i])
    else:
        print("未发现数据库文件，创建并建立基线......")
        for keyword in keywords:
            payload = keyword.split('+')
            for i in range(0, len(tUrls)):
                #关键词和payload同时存在则加入到target_codes,并写入数据库
                if (payload[0] in codes[i]) and (payload[1] in codes[i]):
                    target_codes.append('<br><br><br>' + '链接：' +tUrls[i] + '<br><br>')
                    target_codes.append('简要代码如下：<br><div style="border:1px solid #bfd1eb;background:#f3faff">' + codes[i] + '</div>')
                    insert_DB(tUrls[i], codes[i])
    #当target_codes有数据时，则进行邮件预警                
    if target_codes:
        warning = ''.join(target_codes)
        result = 'Dear all<br><br>发现信息泄露! ' + '一共发现{}条'.format(int(len(target_codes)/2)) + warning
        send_mail(host, m_User, m_Pass, m_sender, receivers, result)
    else:
        send_mail(host, m_User, m_Pass, m_sender, receivers, message)
