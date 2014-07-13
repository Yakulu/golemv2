(function () {
  var l = golem.utils.locale;
  var menus = golem.menus;
  var member = golem.module.member;
  member.data = {
    items: [],
    labels: { tels: [], mails: [] },
    menuItems: {
      list: new menus.Item(l('MENU_LIST'), '/member/list', 'list'),
      add: new menus.Item(l('MENU_NEW'), '/member/add', 'add sign'),
      skills: new menus.Item(l('SKILLS'), '/member/skills', 'skills'),
      tags: new menus.Item(l('MENU_TAGS'), '/member/tags', 'tags'),
      show: new menus.Item(l('VIEW'), '/member/show', 'search'),
      edit: new menus.Item(l('EDIT'), '/member/edit', 'edit'),
      remove: new menus.Item(l('DELETE'), '/member/remove', 'remove')
    },
    tags: [],
    getTags: golem.module.contact.data.getTags,
    skills: []
  };
}).call(this);
