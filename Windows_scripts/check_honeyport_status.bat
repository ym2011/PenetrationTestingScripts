@echo off
REM author：kym
REM date: 2021-07-07
REM purpose：check the honeyport ports status
title honeyport running  status.
echo The work runs for a while,please wait................
call:server_port
call:pro-02_port
call:pro-01_port
call:dev-01_port
pause
exit /b 0

:server_port
set serverip=10.10.7.8
set serverport=135
start telnet.exe %serverip% %serverport%

tasklist|findstr /i "telnet.exe"
if ERRORLEVEL 1 (goto close) else (goto open)


:open
taskkill /F -IM "telnet.exe" 
echo %serverip% %serverport% is open %Date:~0,4%-%Date:~5,2%-%Date:~8,2% %Time:~0,2%:%Time:~3,2%
GOTO:EOF

:close
echo %serverip% %serverport% is closed or unable to connect.%Date:~0,4%-%Date:~5,2%-%Date:~8,2% %Time:~0,2%:%Time:~3,2%
GOTO:EOF


:pro-02_port
set pro-02-ip=10.0.6.227
set pro-02-port=135
start telnet.exe %pro-02-ip% %pro-02-port%

tasklist|findstr /i "telnet.exe"
if ERRORLEVEL 1 (goto close) else (goto open)

:open
taskkill /F -IM "telnet.exe" 
echo %pro-02-ip% %pro-02-port% is open %Date:~0,4%-%Date:~5,2%-%Date:~8,2% %Time:~0,2%:%Time:~3,2%
GOTO:EOF

:close
echo %pro-02-ip% %pro-02-port% is closed or unable to connect.%Date:~0,4%-%Date:~5,2%-%Date:~8,2% %Time:~0,2%:%Time:~3,2%
GOTO:EOF


:pro-01_port 
set pro-01-ip=10.1.21.237
set pro-01-port=135

start telnet.exe %pro-01-ip% %pro-01-port%
tasklist|findstr /i "telnet.exe"
if ERRORLEVEL 1 (goto close) else (goto open)

:open
taskkill /F -IM "telnet.exe" 
echo %pro-01-ip% %pro-01-port% is open %Date:~0,4%-%Date:~5,2%-%Date:~8,2% %Time:~0,2%:%Time:~3,2%
GOTO:EOF

:close
echo %pro-01-ip% %pro-01-port% is closed or unable to connect.%Date:~0,4%-%Date:~5,2%-%Date:~8,2% %Time:~0,2%:%Time:~3,2%
GOTO:EOF

:dev-01_port 
set dev-01-ip=10.10.0.45
set dev-01-port=135
start telnet.exe %dev-01-ip% %dev-01-port%
tasklist|findstr /i "telnet.exe"
if ERRORLEVEL 1 (goto close) else (goto open)

:open
taskkill /F -IM "telnet.exe" 
echo %dev-01-ip% %dev-01-port% is open %Date:~0,4%-%Date:~5,2%-%Date:~8,2% %Time:~0,2%:%Time:~3,2%
GOTO:EOF

:close
echo %dev-01-ip% %dev-01-port% is closed or unable to connect.%Date:~0,4%-%Date:~5,2%-%Date:~8,2% %Time:~0,2%:%Time:~3,2%
GOTO:EOF

