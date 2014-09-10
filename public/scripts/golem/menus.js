(function () {
  var menus = golem.menus = {
    Item: function (title, baseUrl, icon, cls) {
      this.title = title;
      this.baseUrl = baseUrl;
      this.icon = icon;
      this.cls = cls || 'item';
      this.url = this.baseUrl;
    },
    itemDom: function (item) {
      var cls = item.cls;
      if (window.location.hash.indexOf(item.url) !== -1) {
        cls += ' active';
      }
      return m('a',
        {
          class: cls,
          href: '#' + item.url,
          // Temp fix for laggy rendering
          //config: m.route
        },
        [
          m('i', { class: item.icon + ' icon' }),
          item.title
        ]
      );
    }
  };
  menus.main = {
    model: {
      items: (function () {
        var l = golem.utils.locale;
        return [
          new menus.Item(l('MENU_HOME'), '/home', 'home'),
          new menus.Item(l('MENU_CONTACTS'), '/contact', 'book', 'item disabled'),
          //new menus.Item(l('MENU_FAMILIES'), '/family', 'sitemap'),
          new menus.Item(l('MENU_MEMBERS'), '/member', 'user'),
          new menus.Item(l('MENU_MESSAGES'), '/mail', 'mail', 'item disabled'),
          new menus.Item(l('MENU_ACTIVITIES'), '/activity', 'globe'),
          new menus.Item(l('MENU_STATISTICS'), '/stats', 'pie chart basic', 'item disabled'),
          new menus.Item(l('MENU_ADMINISTRATION'), '/admin', 'wrench', 'item disabled')
        ];
      }).call(this),
      addItem: function (title, baseUrl, icon, cls) {
        menus.main.model.items.push(new menus.Item(title, baseUrl, icon, cls));
      }
    },
    controller: function () {},
    view: function (ctrl) {
      return m('nav', [
        m('menu', {
          id: 'main-menu',
          class: 'ui vertical labeled icon menu'
        },
        menus.main.model.items.map(menus.itemDom)
        )
      ]);
    }
  };
  menus.secondary = {
    items: [],
    view: function () {
      return m('nav', [
        m('menu', {
          class: 'ui small secondary pointing menu'
        },
        menus.secondary.items.map(menus.itemDom)
        )
      ]);
    }
  };
}).call(this);
