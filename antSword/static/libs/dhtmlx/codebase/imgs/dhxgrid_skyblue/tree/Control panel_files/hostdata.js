// 
// 主机列表
// 

define({
    parseUA: function(ua) {
        var info = {};
        var temp = {};
        info.ua = ua;
        temp.os = {
            'Mac OS X': /Mac OS X ([\d\.\_]+)/,
            'iPhone OS': /iPhone OS ([\d\.\_]+)/,
            'iPad': /iPad; CPU OS ([\d\_\.]+)/,
            'Android': /Android ([\d\.]+)/,
            'Windows Phone': /Windows Phone (OS )?([\d\.]+)/,
            'BlackBerry': /BlackBerry[ ]?[\d]+/,
            'Symbian': /SymbianOS\/([\d\.]+)/,
            'Windows': /Windows NT ([\d\.]+)/,
            'Linux': /Linux ([\w\d]+)/
        }
        for (var o in temp.os){
            if (info.ua.indexOf(o)) {
                var m = info.ua.match(temp.os[o]);
                info.os = m ? m[0] : (info.os || 'Unknow OS');
            };
        }
        temp.browser = {
            'Safari': /Safari\/([\d\.]+)$/,
            'Chrome': /Chrome\/([\d\.]+)/,
            'Firefox': /Firefox\/([\d\.]+)$/,
            'Opera/': /Version\/([\d\.]+)$/,
            'MSIE': /MSIE ([\d\.]+)/,
            'Lunascape': /Lunascape ([\d\.]+)/,
            'Netscape': /Netscape6[\d]?\/([\d\.]+)/,
            'CriOS': /CriOS\/([\d\.]+)/,
            'UCBrowser': /UCBrowser\/([\d\.]+)/,
            'Trident': /Trident\/([\d\.]+)/,
            'baiduboxapp': /baiduboxapp\/([\d\.\_]+)/,
            'MiuiBrowser': /MiuiBrowser\/([\d\.]+)$/
        }
        for (var b in temp.browser){
            if (info.ua.indexOf(b)) {
                var m = info.ua.match(temp.browser[b]);
                info.browser = m ? m[0] : (info.browser || 'Unknow Browser');
            };
        }
        return {
            os: info.os,
            browser: info.browser
        }
    },
    // 格式化时间
    formaTime: function(tm) {
        var _tm = new Date(tm);
        return _tm.toLocaleDateString() + ' ' + _tm.toLocaleTimeString();
    },
    getPath: function(p) {
        return './static/js/host/data/' + p;
    },
    init: function(layout) {
        // 初始化cell
        var self = this;
        var cell_host_list = layout.cells('a');
        var windows = new dhtmlXWindows();
        cell_host_list.setText('主机列表');
        // 隐藏header
        cell_host_list.hideHeader();
        // 加载中
        cell_host_list.progressOn();
        // 底部分页栏
        cell_host_list.attachStatusBar({
            height: {dhx_skyblue:30, dhx_web: 31, dhx_terrace: 40}['dhx_skyblue'],
            text: "<div id='cell_host_paging'></div>"
        });

        // 初始化grid
        var grid_host = cell_host_list.attachGrid();
        // grid_host.setIconsPath(dhtmlx.image_path);
        grid_host.setHeader([
            "<i class='fa fa-laptop'></i> IP地址",
            "<i class='fa fa-globe'></i> 地理位置",
            "<i class='fa fa-link'></i> 来源地址",
            "<i class='fa fa-windows'></i> 系统信息",
            "<i class='fa fa-leaf'></i> 浏览器信息",
            "<i class='fa fa-sitemap'></i> 连接状态",
            "<i class='fa fa-clock-o'></i> 连接时间",
            "<i class='fa fa-clock-o'></i> 断开时间"
        ]);
        grid_host.setColTypes("ro,ro,ro,ro,ro,ro,ro,ro");
        // 多行选择
        grid_host.enableMultiselect(true);
        // tree grid
        grid_host.setColTypes("tree,txt,txt,txt,txt,txt,txt,txt");

        grid_host.setColSorting('str,str,str,str,str,str,str,str');
        grid_host.setInitWidths('160,200,*,150,150,100,150,150');
        
        // 右键菜单
        var context_menu = new dhtmlXMenuObject();
        // context_menu.setIconsPath('./codebase/imgs/');
        context_menu.renderAsContextMenu();
        context_menu.loadStruct([
            {
                "id": "del",
                "text": "<i class='fa fa-trash'></i> 删除选中"
            }, {
                "type": "separator"
            }, {
                "id": "vist",
                "enabled": false,
                "text": "<i class='fa fa-external-link'></i> 访问来源"
            }, {
                "type": "separator"
            }, {
                "id": "plugin",
                "text": "<i class='fa fa-puzzle-piece'></i> 加载插件",
                "items": [
                    {
                        "id": "screen",
                        "text": "远程屏幕"
                    }, {
                        "type": "separator"
                    }, {
                        "id": "eval",
                        "text": "代码执行"
                    }
                ]
            }
        ]);
        // 右鍵菜單點擊事件
        context_menu.attachEvent('onClick', function(id, zoneId, cas) {
            if (id == 'screen') {
                var window_screen = windows.createWindow('window_screen' + (+new Date), 0, 0, 600, 400);
                window_screen.attachURL('/static/js/');

                window_screen.setText('测试窗口');
                window_screen.centerOnScreen();
                window_screen.button('minmax').show();
                window_screen.button('minmax').enable();
            };
        })
        // context_menu.loadStruct(this.getPath('host_menu.json'));
        grid_host.enableContextMenu(context_menu);


        grid_host.init();
        // 加载json数据
        // grid_host.load(this.getPath('test.json'), null, 'json');
        // grid_host.load(
        //     // 'http://localhost:4000/1000',
        //     this.getPath('test.json'),
        //     function() {
        //         cell_host_list.progressOff();
        //     },
        //     'json'
        // );
        $.getJSON('http://localhost:4000/1000', function(ret) {
            var data = [];
            for (var i = 0; i < ret.length; i ++) {
                _ret = ret[i];
                _ua = self.parseUA(_ret['ua']);
                data.push({
                    "id": i + 1,
                    "data": [
                        '<i class="fa fa-laptop"></i> ' + _ret['ip'],
                        _ret['addr'],
                        _ret['referer'],
                        _ua['os'],
                        _ua['browser'],
                        '-',
                        self.formaTime(_ret['ctime']),
                        self.formaTime(_ret['utime'])
                    ]
                });
            }
            grid_host.clearAll();
            grid_host.parse({
                "rows": data
            }, 'json');
            cell_host_list.progressOff();
        });
        // 设置工具栏
        var toolbar_host = cell_host_list.attachToolbar();
        // toolbar_host.setIconsPath('./static/dhtmlx/samples/dhtmlxToolbar/common/imgs/');
        toolbar_host.loadStruct(this.getPath('toolbar.json'), 'json', function() {});

        // 设置分页
        grid_host.enablePaging(true, 200, 5, "cell_host_paging", true);
        grid_host.setPagingSkin("toolbar");
        // 表格点击事件
        grid_host.attachEvent("onEditCell", function(stage, id, index){

            // var window_test = windows.createWindow('window_test' + (+new Date), 0, 0, 600, 400);
            // window_test.attachURL('/static/js/main.js');

            // window_test.setText('测试窗口');
            // window_test.centerOnScreen();
            // window_test.button('minmax').show();
            // window_test.button('minmax').enable();

            return false; 
        })
        window.GRID = grid_host;
        // 加载结束
        // grid_host.attachEvent("onDataReady",function(){
        //     cell_host_list.progressOff();
        // })
    }
})