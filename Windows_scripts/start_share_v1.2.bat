:: authour: kym 
:: time: 2017-12-14
:: verison: 1.2
:: aimming to start the windows default  share  files.
:: 使用AD域控进行推送脚本的时候，请使用authenticated users 的权限
@echo off
echo *********************************************************
echo 正在修复您的系统,请稍等片刻!
echo *********************************************************
echo *********************************************************************** >> C:\Users\Public\start_share_result.txt 2>&1

echo 正在开启磁盘共享...
echo %date% %time% ，开启磁盘共享，操作结果如下： >> C:\Users\Public\start_share_result.txt 2>&1

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" /v "AutoShareServer" /t REG_DWORD /d "00000001" /f >> C:\Users\Public\start_share_result.txt 2>&1


echo 正在开启用户共享...
echo %date% %time% ，开启磁盘共享，操作结果如下： >> C:\Users\Public\start_share_result.txt 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" /v "AutoShareWks" /t REG_DWORD  /d "00000001" /f >> C:\Users\Public\start_share_result.txt 2>&1

echo %date% %time% ，开启用户共享，操作结果如下： >> C:\Users\Public\start_share_result.txt 2>&1
net share users=C:\Users >> C:\Users\Public\start_share_result.txt 2>&1

echo %date% %time% ，开启打印共享，操作结果如下： >> C:\Users\Public\start_share_result.txt 2>&1
net share print$=C:\Windows\System32\spool\drivers >> C:\Users\Public\start_share_result.txt 2>&1

echo *********************************************************
echo 修复完成，请重启电脑!
echo *********************************************************
echo *********************************************************************** >> C:\Users\Public\start_share_result.txt 2>&1
:: del %0
pause