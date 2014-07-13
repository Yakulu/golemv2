(function () {
  var l = golem.utils.locale;
  var menus = golem.menus;
  var family = golem.module.family;
  family.data = {
    items: [],
    labels: { tels: [], mails: [] },
    menuItems: {
      list: new menus.Item(l('MENU_LIST'), '/family/list', 'list'),
      add: new menus.Item(l('MENU_NEW'), '/family/add', 'add sign'),
      show: new menus.Item(l('VIEW'), '/family/show', 'search'),
      edit: new menus.Item(l('EDIT'), '/family/edit', 'edit'),
      remove: new menus.Item(l('DELETE'), '/family/remove', 'remove')
    }
  };
}).call(this);
