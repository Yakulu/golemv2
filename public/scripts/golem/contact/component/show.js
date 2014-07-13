(function () {
  var contact = golem.module.contact;
  contact.component.show = {
    controller: function () {
      var l = golem.utils.locale;
      var key = m.route.param('contactId');
      m.startComputation();
      golem.model.db.get(key, (function (err, res) {
        this.contact = res;
        document.title = golem.model.title(l('CONTACTS_DETAIL') +
          contact.model.fullname(this.contact));
        var cmi = contact.data.menuItems;
        ['show', 'edit', 'remove'].forEach((function (v) {
          cmi[v].url = cmi[v].baseUrl + '/' + this.contact._id;
        }).bind(this));
        golem.menus.secondary.items = [
          cmi.list, cmi.add, cmi.show, cmi.edit, cmi.remove
        ];
        m.endComputation();
      }).bind(this));
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var c = ctrl.contact;
      var format = {
        default: function (def) {
          if (def) {
            return m('span', [
              m('i', {
                class: 'checkmark icon green',
                title: l('DEFAULT')
                }
              )
            ]);
          }
        },
        tels: function (item) {
          return m('li', [
            item.label + ' : ',
            m('a', { href: 'tel:' + item.value },
              item.value.match(/\d{2}/g).join('.')),
            format.default(item.default)
          ]);
        },
        mails: function (item) {
          return m('li', [
            item.label + ' : ',
            m('a', { href: 'mailto:' + item.value }, item.value),
            format.default(item.default)
          ]);
        },
        www: function (item) {
          return m('li', [ m('a', { href: item }, item) ]);
        }
      };
      var groupsBox = (function () {
        if (c.groups.length === 0) {
          return m('p', l('GROUPS_NONE'));
        } else {
          return m('p', [
            m('div', { class: 'ui green label'}, l('MENU_GROUPS')),
            m('ul', { class: 'ui horizontal bulleted list' }, c.groups.map(function (group) {
              return m('li', { class: 'item' }, group);
            }))
          ]);
        }
      }).call();
      var multiBox = function (items, header, formatFn) {
        if (items.length > 0) {
          return m('div', [
            m('div', { class: 'ui black label' }, header),
            m('ul', items.map(formatFn))
          ]);
        }
      };
      mainContent = m('section', { class: 'ui piled segment' }, [
        m('div', { class: 'ui floated right basic segment' },
          c.tags.map(function (tag) {
            return m('a', {
                class: 'ui small teal label golem-tag',
                href: '#/contact/list/filter/tag/' + tag,
                title: l('CONTACTS_BY_TAGS'),
                //config: m.route
              }, [
              m('i', { class: 'tag icon' }),
              tag
            ]);
          })
        ),
        m('h2', contact.model.fullname(c)),
        m('p', m.trust(c.note)),
        m('div', { class: 'ui two column grid' }, [
          m('div', { class: 'column' }, [
            m('p', [
              m('div', { class: 'ui label' }, l('CONTACT_DETAILS')),
              m('div', contact.model.fulladdress(c))
            ]),
            m('div', groupsBox)
          ]),
          m('div', { class: 'column' }, [
            m('p', [
              multiBox(c.tels, l('TELS'), format.tels),
              multiBox(c.mails, l('MAILS'), format.mails),
              multiBox(c.www, l('WWW'), format.www)
            ])
          ])
        ])
      ]);
      return [
        m('section', { class: 'sixteen wide column' }, [
          new golem.menus.secondary.view(), mainContent
        ])
      ];
    }
  };
}).call(this);
