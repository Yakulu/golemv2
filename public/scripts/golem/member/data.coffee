l = golem.config.locale
menus = golem.menus
member = golem.module.member
member.data =
  items: []
  menuItems:
    list: new menus.Item l.LIST, '/member/list', 'list'
    add: new menus.Item l.NEW, '/member/add', 'add sign'
    skills: new menus.Item l.SKILLS, '/member/skills', 'briefcase'
    tags: new menus.Item l.TAGS, '/member/tags', 'tags'
    show: new menus.Item l.VIEW, '/member/show', 'search'
    edit: new menus.Item l.EDIT, '/member/edit', 'edit'
    remove: new menus.Item l.DELETE, '/member/remove', 'remove'
    duplicate: new menus.Item l.DUPLICATE, '/member/duplicate', 'copy'
  tags: []
  skills: []

member.data.getTags = golem.model.getTags.bind null, 'member', 'member', 'tags'
member.data.getSkills = golem.model.getTags.bind null, 'memberskills', 'member', 'skills'
