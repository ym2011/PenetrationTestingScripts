// 
// 访客/主机管理
// 

define(
    ['./category', './countdata', './logger', './hostdata'],
    function(category, countdata, logger, hostdata) {
        return {
            init: function(tabbar) {
                tabbar.addTab('tab_host', '<i class="fa fa-desktop"></i> 访客管理');
                var tab_host = tabbar.cells('tab_host');
                tab_host.setActive();
                // layout
                var layout_host = tab_host.attachLayout('4T');
                // 主机列表
                hostdata.init(layout_host);
                // 分类目录
                category.init(layout_host);
                // 统计视图
                countdata.init(layout_host);
                // 日志管理
                logger.init(layout_host);
            }
        }
    }
);