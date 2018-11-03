// 
// 项目管理
// 

(function (){
    var PROJECT = {
        init: function(tabbar) {
            tabbar.addTab('tab_project', '<i class="fa fa-th-large"></i> 项目管理');
            var tab_project = tabbar.cells('tab_project');
            var layout_2 = tab_project.attachLayout('2U');

            this.category.init(layout_2);
            this.editor.init(layout_2);
        }
    };
    define(
        ['./category', './editor'],
        function (category, editor) {
            PROJECT.editor = editor;
            PROJECT.category = category;
            return PROJECT;
        }
    );
})();