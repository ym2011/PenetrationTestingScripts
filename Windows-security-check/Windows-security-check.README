# 日期：2016-07-14
# 作者：ym

目前windows安全检查脚本实现的功能有如下几点：

1、系统信息检查

2、端口状态检查

3、添加/卸载记录

4、IE浏览器记录

5、用户检查

6、隐藏用户检查

7、进程检查

8、注册表启动项检查

9、通信检查

10、CMD使用记录检查

11、C盘部分文件夹捆绑文件检查


# 这里有一个使用重点：如果是涉及到注册表检查的，需要给注册表赋予权限，通过reg query来读取，大部分注册表是不允许直接读取的。

HKEY_LOCAL_MACHINE\SAM\SAM\Domains\Account\Users\Names [1 2 19]
注册表相关权限如下：

用regini，是系统自带的注册表权限工具
1   - Administrators 完全访问
2   - Administrators 只读访问
3   - Administrators 读和写入访问 
4   - Administrators 读、写入、删除访问 
5   - Creator 完全访问
6   - Creator 读和写入访问 
7   - everyone 完全访问
8   - everyone 只读访问
9   - everyone 读和写入访问 
10 - everyone 读、写入、删除访问 
11 - Power Users 完全访问
12 - Power Users 读和写入访问 
13 - Power Users 读、写入、删除访问 
14 - System Operators 完全访问
15 - System Operators 读和写入访问 
16 - System Operators 读、写入、删除访问 
17 - System 完全访问
18 - System 读和写入访问 
19 - System 只读访问
20 - Administrators 读、写、执行访问
21 - Interactive User 完全访问
22 - Interactive User 读和写入访问 
23 - Interactive User 读、写入、删除访问

命令格式为HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run [2 9 19]
