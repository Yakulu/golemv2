(function () {
  var l = golem.config.locale;
  var menus = golem.menus;
  var activity = golem.module.activity;
  activity.data = {
    items: [],
    menuItems: {
      list: new menus.Item(l.MENU_LIST, '/activity/list', 'list'),
      add: new menus.Item(l.MENU_NEW, '/activity/add', 'add sign'),
      show: new menus.Item(l.VIEW, '/activity/show', 'search'),
      edit: new menus.Item(l.EDIT, '/activity/edit', 'edit'),
      remove: new menus.Item(l.DELETE, '/activity/remove', 'remove')
    }
  };
}).call(this);
