// 
// 系统设置
// 

define({
    init: function(tabbar) {
        tabbar.addTab(
            'tab_setting',
            '<i class="fa fa-cog"></i> 系统设置'
        );
        window.TEST = tabbar.cells('tab_setting');
    }
})