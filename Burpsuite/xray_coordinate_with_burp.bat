:: authour: ym2011
:: time: 2020-12-08
:: verison: 1.1

@echo off
title xray runs, coordinating with burpsuite

set YYYYmmdd=%date:~0,4%%date:~5,2%%date:~8,2%
set hhmiss=%time:~0,2%%time:~3,2%%time:~6,2%
set report=xray_report_%YYYYmmdd%_%hhmiss%.html

goto comment
联动burp说明：https://docs.xray.cool/#/scenario/burp
引擎初次运行时，会在当前目录内生成一个 config.yaml 文件
按需进行修改config.yaml的配置
配置文件说明；https://docs.xray.cool/#/configration/config
restriction:
    includes: # 允许扫描的域，此处无协议
    - '*' # 表示允许所有的域名和 path
    - 'example.com' # 表示允许 example.com 下的所有 path
    - "example.com/admin*" # 表示允许 example.com 下的 /admin 开头的 path
    excludes:
    - '*google*'
    - '*github*'
    - '*.gov.cn'
    - '*.edu.cn'
    - '*chaitin*'
    - '*xray.cool'
:comment

echo ****************************************
echo Do not run xray when repeat the packet within burpsuite.
echo It will delete or create hundred of contents automatically.

if not exist ca.crt (
	goto generaca
) else (
goto backup
)

:generaca
echo ****************************************
echo **** genering ca.crt and ca.key ********
.\xray_windows_amd64.exe genca
echo generaca successfully.

:backup
if exist proxy.html (
	goto backupreport
) else (
goto start
)

:backupreport
echo ****************************************
echo **** old report is backuping now *******
copy proxy.html %report%
echo successfully,it's name is: %report%.
del proxy.html

:start
rem 如果需要扫描教育政府类网站，请在config.yaml注释掉（前面加#），如# - '*.gov.cn'
rem 1、powershell 执行监听爬虫，联动burp
:: .\xray_windows_amd64.exe webscan --listen 127.0.0.1:7777 --html-output proxy.html
echo ****************************************
echo ********now, xary started***************
echo ****************************************

.\xray_windows_amd64.exe webscan --listen 127.0.0.1:7777 --html-output proxy.html

rem 2、使用 xray 基础爬虫模式进行漏洞扫描
:: .\xray_windows_amd64 webscan --basic-crawler http://testphp.vulnweb.com/ --html-output 1.html

rem 自1.2.0开始，高级版新增浏览器爬虫支持
::.\xray_windows_amd64 webscan --browser-crawler  http://testphp.vulnweb.com/ --html-output 2.html

pause