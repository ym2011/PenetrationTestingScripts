// 
// 日志管理
// 

define({
    init: function(layout) {
        var cell_host_log = layout.cells('d');
        cell_host_log.setHeight('350')
        cell_host_log.setText('<i class="fa fa-info-circle"></i> 日志管理');
        // cell_host_log.setWidth('550');


        // 日志表格

        var grid_host_log = cell_host_log.attachGrid();
        // grid_host_log.setIconsPath('./codebase/imgs/');
        
        grid_host_log.setHeader(["时间","类型","内容"]);
        grid_host_log.setColTypes("ro,ro,ro");
        
        grid_host_log.setColSorting('str,str,str');
        grid_host_log.setInitWidths('100,100,*');
        grid_host_log.init();
        grid_host_log.load('./data/host_log.json', 'json');
    }
});