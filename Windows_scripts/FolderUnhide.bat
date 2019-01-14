:: To disclosure the folders 
:: Author : ym20111
:: Date: 2018-12-19
@echo off
echo ==================================================================
echo ==============================================================
echo ==========================================================
echo please waiting for a while, you can go have a  tea, return later
echo It is working for your purpose
echo ...............................
echo .............
echo ....
for /f "delims=" %%i in ('dir /ah /s/b') do attrib "%%i" -s -h
echo it done!, please close it
echo Goodbye
pause
del %0