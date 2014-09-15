l = golem.config.locale
menus = golem.menus
golem.module.activity.data =
  items: []
  menuItems:
    list: new menus.Item l.LIST, '/activity/list', 'list'
    add: new menus.Item l.NEW, '/activity/add', 'add sign'
    show: new menus.Item l.VIEW, '/activity/show', 'search'
    edit: new menus.Item l.EDIT, '/activity/edit', 'edit'
    remove: new menus.Item l.DELETE, '/activity/remove', 'remove'
