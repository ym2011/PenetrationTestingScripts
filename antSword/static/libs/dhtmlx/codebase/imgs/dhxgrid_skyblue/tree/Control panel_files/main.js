$(document).ready(function() {
    require.config({
        baseUrl: '/static/js'
    });

    require(
        ['host/index', 'project/index', 'setting/index'],
        function (host, project, setting) {
            dhtmlx.image_path='static/dhtmlx/codebase/imgs/';
            var tabbar = new dhtmlXTabBar(document.body);

            host.init(tabbar);
            project.init(tabbar);
            setting.init(tabbar);
        }
    );
});