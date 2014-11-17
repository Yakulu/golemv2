l = golem.config.locale
menus = golem.menus
contact = golem.module.contact
contact.data =
  items: []
  menuItems:
    list: new menus.Item l.LIST, '/contact/list', 'list'
    add: new menus.Item l.NEW, '/contact/add', 'add sign'
    tags: new menus.Item l.TAGS, '/contact/tags', 'tags'
    show: new menus.Item l.VIEW, '/contact/show', 'search'
    edit: new menus.Item l.EDIT, '/contact/edit', 'edit'
    remove: new menus.Item l.DELETE, '/contact/remove', 'remove'
  tags: []

contact.data.getTags = golem.model.getTags.bind null, 'contact', 'contact', 'tags'
