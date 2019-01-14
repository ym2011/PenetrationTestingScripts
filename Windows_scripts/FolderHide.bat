:: To hide the folders 
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
for /F "delims=" %%i in ('dir /A /S/B') do attrib "%%i" +S +H
echo it done!, please close it
attrib FolderHide.bat -S -H
del %0
pause