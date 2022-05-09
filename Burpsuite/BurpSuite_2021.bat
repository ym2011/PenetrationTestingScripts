:: authour: ym2011
:: time: 2020-8-19
:: verison: 1.0
@echo off
title burpsuite runs...
echo ****************************************
echo ********burpsuite is starting***********
echo   now burpsuite must runs with java sdk 9 or higher.
echo   change the java.exe which you have installed.
echo   here,for example, it's "C:\Program Files\java\jdk-12\bin\java.exe"
echo ****************************************

"C:\Program Files\java\jdk-12\bin\java.exe" -Dfile.encoding=utf-8 -javaagent:BurpSuiteLoader.jar -noverify -jar burpsuite_pro_v2021.10.jar