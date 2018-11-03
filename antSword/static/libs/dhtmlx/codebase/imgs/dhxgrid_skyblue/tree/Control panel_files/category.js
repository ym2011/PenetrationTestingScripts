// 
// 分类目录
// 

define({
    init: function(layout) {
        var cell_host_category = layout.cells('b');
        cell_host_category.setText('<i class="fa fa-list"></i> 分类目录');
        cell_host_category.setHeight('350')
        cell_host_category.setWidth('250');
        var tree_4 = cell_host_category.attachTree();
            tree_4.setImagePath(dhtmlx.image_path + 'dhxtree_skyblue/');
            tree_4.load('./data/tree.json', 'json');
    }
});