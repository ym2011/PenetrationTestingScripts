:: Init Script for cmd.exe
:: Created as part of batch_scan
:: #########################################################################
:: 1 如果你是首次运行该程序，请设置：主界面--工具--一般--用户文件的文件夹(D:\appscan\result);日志文件的文件夹(D:\appscan\Logs)
:: 2 如果你是首次运行该程序，请设置：主界面--工具--扫描选项--指示扫描是否完成(勾选)、扫描过程中自动保存(勾选)
@REM 3 如果你是首次运行该程序，请设置：主界面--扫描--扫描配置--测试--测试策略--选择好策略后导出到D:\appscan\attack.scant 
@REM 4 如果你是32位系统，请将路径C:\Program Files (x86)\IBM\AppScan Standard 改为 C:\Program Files\IBM\AppScan Standard

::@mode con cp select=936
@chcp 936
echo 1 如果你是首次运行该程序，请设置：主界面--工具--一般--用户文件的文件夹(D:\appscan\result);日志文件的文件夹(D:\appscan\Logs)
echo 2 如果你是首次运行该程序，请设置：主界面--工具--扫描选项--指示扫描是否完成(勾选)、扫描过程中自动保存(勾选)
echo 3 如果你是首次运行该程序，请设置：主界面--扫描--扫描配置--测试--测试策略--选择好策略后导出到D:\appscan\attack.scant 
echo 4 如果你是32位系统，请将路径C:\Program Files (x86)\IBM\AppScan Standard 改为 C:\Program Files\IBM\AppScan Standard
echo 5 在当前目录的每个urltoscan文件中，分别保存3个URl。因为经过测试发现，同时进行三个扫描是性能和效率最高的。
@echo off
@REM delete the script created by the last time
::@DEL urltoscan*.bat
@REM set AppScanCMD_home
@echo off
SET home=%CD%
SET AppScan_ROOT=C:\Program Files (x86)\IBM\AppScan Standard
@REM change to the path where AppScan was installed

@REM produce batch_scan for appscancm 
::for /F "delims=/,tokens=3" %%f in (urltoscan.txt) do echo %%f >> urltoname.txt


::在每个urltoscan文件中，保存3个URl。因为经过测试发现，同时进行三个扫描是性能和效率最高的。
for /F %%u in (urltoscan0.txt) do echo %AppScan_ROOT%/appscancmd /e /su %%u /st %home%\attack.scant /d %home%\result\ /v >> urltoscan0.bat
for /F %%u in (urltoscan1.txt) do echo %AppScan_ROOT%appscancmd /e /su %%u /st %home%\attack.scant /d %home%\result\ /v >> urltoscan1.bat
for /F %%u in (urltoscan2.txt) do echo %AppScan_ROOT%appscancmd /e /su %%u /st %home%\attack.scant /d %home%\result\ /v >> urltoscan2.bat

echo "即将启动，请稍等！" 
start urltoscan1.bat
start urltoscan2.bat
start urltoscan3.bat








