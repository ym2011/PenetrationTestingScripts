echo off
color a
cls
set ip=www.baidu.com
set qt=0
set ok=0
set of=0
set zj=0
set aa=0
echo off
color a
:a
cls
title  连接成功：%ok%次   连接失败：%of%次   网卡错误：%zj%次   未知错误：%qt%次
echo/
echo/  成功、失败、错误、未知,单项累计200次以上会自动关闭，总计500次以上会自动关闭！
echo/
echo/
echo/      连接成功：%ok%次
echo/
echo/      连接失败：%of%次
echo/
echo/      网卡错误：%zj%次
echo/
echo/      未知错误：%qt%次
echo/
echo/
echo/                 总计：%aa%次
echo/
echo/
echo/
echo/   -本地客户端-------^> %ip% ^<-------指向服务端----小铁-----
echo/                                       
if %ok% gtr 200 exit
if %of% gtr 200 exit
if %zj% gtr 200 exit
if %qt% gtr 200 exit
set/a aa+=1
ping %ip% -n 1 >nul
if %errorlevel% equ 1 (set/a of+=1 &goto a)
if %errorlevel% equ 0 (set/a ok+=1 &goto a)
if %errorlevel% lss 0 (set/a zj+=1 &goto a)
set/a qt+=1
goto a
