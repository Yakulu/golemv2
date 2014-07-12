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
    },
    main: {
      controller: function () {
        var l = golem.utils.locale;
        this.items = [
          new menus.Item(l('MENU_HOME'), '/home', 'home'),
          new menus.Item(l('MENU_CONTACTS'), '/contact', 'book'),
          new menus.Item(l('MENU_MEMBERS'), '/member', 'user'),
          new menus.Item(l('MENU_MESSAGES'), '/mail', 'mail', 'item disabled'),
          new menus.Item(l('MENU_ACTIVITIES'), '/activity', 'globe'),
          new menus.Item(l('MENU_STATISTICS'), '/stats', 'pie chart basic', 'item disabled')
          ];

          this.addItem = function (title, baseUrl, icon, cls) {
            this.items.push(new menus.Item(title, baseUrl, icon, cls));
          };
      },
      view: function (ctrl) {
        return m('nav', [
          m('menu', {
              id: 'main-menu',
              class: 'ui vertical labeled icon menu'
            },
            ctrl.items.map(menus.itemDom)
          )
        ]);
      }
    },
    secondary: {
      controller: function () {
        this.items = [];

        this.replace = function (items) {
          this.items = items;
        };
      },
      view: function (ctrl) {
        return m('nav', [
          m('menu', {
              class: 'ui small secondary pointing menu'
            },
            ctrl.items.map(menus.itemDom)
          )
        ]);
      }
    }
  };
}).call(this);
