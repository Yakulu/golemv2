(function () {
  var module = golem.module.activity;
  module.component.list = {
    controller: function () {
      var l = golem.utils.locale;
      var mi = module.data.menuItems;
      golem.menus.secondary.items = [ mi.list, mi.add ];
      document.title = golem.model.title(l('ACTIVITIES_LIST'));
      this.items = [];
      this.search = (function (e) {
        this.filteredItems = golem.component.list.search(e, this.items);
      }).bind(this);
      var callback = (function (err, results) {
        this.items = results.rows;
        m.endComputation();
      }).bind(this);
      var getActivities = (function () {
        m.startComputation();
        golem.model.getBySchema('activity', callback);
			}).bind(this)
      getActivities();
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var itemDom = function (i) {
        i = i.doc;
        return m('tr', [
          m('td', i.label),
          m('td', i.code),
          m('td', i.timeSlot),
          m('td', i.monitor),
          m('td', i.places),
          m('td', { class: 'actions' }, [
            m('a', { href: '#/activity/show/' + i._id, title: l('VIEW') }, [
              m('i', { class: 'unhide icon' })
            ]),
            m('a', { href: '#/activity/edit/' + i._id, title: l('EDIT') }, [
              m('i', { class: 'edit icon' })
            ]),
            m('a', { href: '#/activity/remove/' + i._id, title: l('DELETE') }, [
              m('i', { class: 'remove icon' })
            ])
          ])
        ]);
      };
      var mainContent = m('table', { class: 'ui basic table' }, [
        m('thead', [
          m('tr', [
            m('th', l('LABEL')),
            m('th', l('CODE')),
            m('th', l('TIMESLOT')),
            m('th', l('MONITOR')),
            m('th', l('PLACES')),
            m('th', { width: '10%' }, l('ACTIONS'))
          ])
        ]),
        m('tbody', ctrl.filteredItems ? ctrl.filteredItems.map(itemDom) : ctrl.items.map(itemDom))
      ]);
      var searchBox = golem.component.list.searchBox(ctrl.search);
      var contextMenuContent = m('nav', [
        m('menu', { class: 'ui small vertical menu' }, [
          searchBox.head, searchBox.content
        ])
      ]);
      return [
        m('section', { class: 'twelve wide column' }, [
          new golem.menus.secondary.view(), mainContent
        ]),
        m('section', { class: 'four wide column' }, contextMenuContent)
      ];
    }
  };
}).call(this);
