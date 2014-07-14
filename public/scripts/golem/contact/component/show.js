(function () {
  var module = golem.module.contact;
  module.component.show = {
    controller: function () {
      var l = golem.utils.locale;
      var key = m.route.param('contactId');
      m.startComputation();
      golem.model.db.get(key, (function (err, res) {
        this.contact = res;
        document.title = golem.model.title(l('CONTACTS_DETAIL') +
          module.model.fullname(this.contact));
        var cmi = module.data.menuItems;
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
      var gcs = golem.component.show;
      var mainContent = m('section', { class: 'ui piled segment' }, [
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
        m('h2', module.model.fullname(c)),
        m('p', m.trust(c.note)),
        m('div', { class: 'ui two column grid' }, [
          m('div', { class: 'column' }, [
            m('p', [
              m('div', { class: 'ui label' }, l('CONTACT_DETAILS')),
              m('div', module.model.fulladdress(c))
            ])
          ]),
          m('div', { class: 'column' }, [
            m('p', [
              gcs.multiBox(c.tels, l('TELS'), gcs.format.tels),
              gcs.multiBox(c.mails, l('MAILS'), gcs.format.mails),
              gcs.multiBox(c.www, l('WWW'), gcs.format.www)
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
