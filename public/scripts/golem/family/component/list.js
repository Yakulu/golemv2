(function () {
  var module = golem.module.family;
  module.component.list = {
    controller: function (fromMember, memberCtrl) {
      this.fromMember = fromMember || false;
      this.memberCtrl = memberCtrl || null;
      var l = golem.utils.locale;
      var mi = module.data.menuItems;
      if (!this.fromMember) { golem.menus.secondary.items = [ mi.list, mi.add ]; }
      document.title = golem.model.title(l('FAMILIES_LIST'));
      this.search = (function (e) {
        this.filteredItems = golem.component.list.search(e, this.items);
      }).bind(this);
      // Init
      this.items = [];
      var getFamilies = (function () {
        m.startComputation();
        golem.model.db.query(
          'all/bySchema',
          {
            startkey: ['family'],
            endkey: ['family', {}],
            include_docs: true
          }, (function (err, res) {
            this.items = res.rows;
            m.endComputation(); 
          }).bind(this)
        );
      }).bind(this);
      getFamilies();
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var actionsDom = function (f) {
        if (ctrl.fromMember) {
          return m('button', {
            class: 'positive ui small button',
            onclick: ctrl.memberCtrl.family.bind(ctrl.memberCtrl, f)
          }, l('OK'));
        } else {
          return [
            m('a', { href: '#/family/show/' + f._id }, [
              m('i', { class: 'unhide icon' })
            ]),
            m('a', { href: '#/family/edit/' + f._id }, [
              m('i', { class: 'edit icon' })
            ]),
            m('a', { href: '#/family/remove/' + f._id }, [
              m('i', { class: 'remove icon' })
            ])
          ];
        }
      };
      var itemDom = function (f) {
        f = f.doc;
        return m('tr', [
          m('td', f.lastname),
          m('td', f.postalCode + ' ' + f.city),
          m('td', f.tels.map(function (tel) {
            if (tel.default) {
              return tel.value.match(/\d{2}/g).join('.');
            }
          })),
          m('td', f.mails.map(function (mail) {
            if (mail.default) {
              return m('a', { href: 'mailto:' + mail.value }, mail.value);
            }
          })),
          m('td', { class: 'actions' }, actionsDom(f))
        ]);
      };
      var itemsDom = ctrl.filteredItems ? ctrl.filteredItems.map(itemDom) : ctrl.items.map(itemDom);
      var mainContent = m('section', { class: 'twelve wide column' }, [
        m('table', { class: 'ui basic table' }, [
          m('thead', [
            m('tr', [
              m('th', l('LASTNAME')),
              m('th', l('CITY')),
              m('th', [
                l('TEL'),
                m('i', { class: 'icon info', title: l('DEFAULT_ONLY') })
              ]),
              m('th', [
                l('MAIL'),
                m('i', { class: 'icon info', title: l('DEFAULT_ONLY') })
              ]),
              m('th', { width: '10%' }, ctrl.fromMember ? l('SELECTION') : l('ACTIONS'))
            ])
          ]),
          m('tbody', itemsDom)
        ])
      ]);
      var searchBox = golem.component.list.searchBox(ctrl.search);
      var contextMenuContent = m('section', { class: 'four wide column' }, 
        m('nav', [
          m('menu', { class: 'ui small vertical menu' }, [
            searchBox.head, searchBox.content
          ])
        ])
      );
      return [
        m('section', { class: 'twelve wide column' }, [
          ctrl.fromMember ? '' : new golem.menus.secondary.view(),
          mainContent
        ]),
        m('section', { class: 'four wide column' }, contextMenuContent)
      ];
    }
  };
}).call(this);