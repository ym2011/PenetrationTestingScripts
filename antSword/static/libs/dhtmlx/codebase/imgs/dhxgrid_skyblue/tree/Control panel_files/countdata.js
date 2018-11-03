// 
// 统计数据
// 

define({
    getPath: function(p) {
        return './static/js/host/data/' + p;
    },
    init: function(layout) {
        var cell_host_data = layout.cells('c');
        cell_host_data.setHeight('350');
        cell_host_data.setText('<i class="fa fa-pie-chart"></i> 统计数据');
        cell_host_data.setWidth('650');



        var tabbar_countdata = cell_host_data.attachTabbar();
        tabbar_countdata.addTab('tab_countdata_devices','设备统计');
        var tab_countdata_devices = tabbar_countdata.cells('tab_countdata_devices');
        tab_countdata_devices.setActive();

        var chart_devices = tab_countdata_devices.attachChart({
            view: 'pie' ,
            tooltip:{
                template:'#count#'
            },
            legend:{"template":"#os#","marker":{"type":"square","width":25,"height":15}},
            gradient: false,
            value:'#count#'
        });

        chart_devices.load(this.getPath('countdata_device.xml'), 'xml');

        // 
        tabbar_countdata.addTab('tab_countdata_browser','浏览器统计');
        var tab_countdata_browser = tabbar_countdata.cells('tab_countdata_browser');

        var chart_browser = tab_countdata_browser.attachChart({
            view: 'pie' ,
            tooltip:{
                template:'#count#'
            },
            legend:{"template":"#browser#","marker":{"type":"square","width":25,"height":15}},
            gradient: false,
            value:'#count#'
        });

        chart_browser.load(this.getPath('countdata_browser.xml'), 'xml');

        // 

        tabbar_countdata.addTab('tab_countdata_addr','地区统计');
        var tab_countdata_addr = tabbar_countdata.cells('tab_countdata_addr');
        var chart_addr = tab_countdata_addr.attachChart({
            view: 'pie' ,
            tooltip:{
                template:'#count#'
            },
            legend:{"template":"#addr#","marker":{"type":"square","width":25,"height":15}},
            gradient: false,
            value:'#count#'
        });

        chart_addr.load(this.getPath('countdata_addr.xml'), 'xml');
        // // 数据图标
        // var chart_1 = cell_host_data.attachChart({
        //     view: 'pie' ,
        //     tooltip:{
        //         template:'#count#'
        //     },
        //     legend:{"template":"#os#","marker":{"type":"square","width":25,"height":15}},
        //     gradient: false,
        //     value:'#count#'
        // });

        // chart_1.load('./data/chart.xml', 'xml');

        // end
    }
});