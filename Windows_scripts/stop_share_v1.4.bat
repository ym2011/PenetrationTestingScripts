:: authour: kym 
:: time: 2018-1-15
:: verison: 1.4
:: aimming to close the windows default  share  files on silence
@echo off
@echo *********************************************************************** >> C:\Users\Public\stop_share_result.txt 2>&1

:: echo *********************************************************
:: echo 正在修复您的系统,请稍等片刻!
:: echo *********************************************************
:: echo 正在关闭磁盘共享...
@echo %date% %time% ，关闭磁盘共享，操作结果如下： >> C:\Users\Public\stop_share_result.txt 2>&1
@reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" /v "AutoShareServer" /t REG_DWORD /d "00000000" /f >> C:\Users\Public\stop_share_result.txt 2>&1

:: echo 正在关闭系统共享...
@echo %date% %time% ，关闭系统共享，操作结果如下： >> C:\Users\Public\stop_share_result.txt 2>&1
@reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" /v "AutoShareWks" /t REG_DWORD  /d "00000000" /f >> C:\Users\Public\stop_share_result.txt 2>&1

@echo %date% %time% ，关闭用户共享，操作结果如下： >> C:\Users\Public\stop_share_result.txt 2>&1
@reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Shares" /v "Users"  /f >> C:\Users\Public\stop_share_result.txt 2>&1
@reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Shares\Security" /v "Users"  /f >> C:\Users\Public\stop_share_result.txt 2>&1

@echo %date% %time% ，关闭打印共享，操作结果如下： >> C:\Users\Public\stop_share_result.txt 2>&1
@reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Shares" /v "print$"  /f >> C:\Users\Public\stop_share_result.txt 2>&1
@reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Shares\Security" /v "print$" /f >> C:\Users\Public\stop_share_result.txt 2>&1


:: echo *********************************************************
:: echo 修复完成，请重启电脑!
:: echo *********************************************************
@echo *********************************************************************** >> C:\Users\Public\stop_share_result.txt 2>&1
:: del %0
exit