(function () {
  var module = golem.module.family;
  module.component.show = {
    controller: function () {
      var l = golem.utils.locale;
      var key = m.route.param('familyId');
      this.family = module.model.create(); // TMP
      m.startComputation();
      golem.model.db.get(key, (function (err, res) {
        this.family = res;
        document.title = golem.model.title(l('DETAILS') +
         this.family.lastname);
        var mi = module.data.menuItems;
        ['show', 'edit', 'remove'].forEach((function (v) {
          mi[v].url = mi[v].baseUrl + '/' + this.family._id;
        }).bind(this));
        golem.menus.secondary.items = [
          mi.list, mi.add, mi.show, mi.edit, mi.remove
        ];
        m.endComputation();
      }).bind(this));
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var f = ctrl.family;
      var gcs = golem.component.show;
      var mainContent = m('section', { class: 'ui piled segment' }, [
        m('h2', f.lastname),
        m('p', m.trust(f.note)),
        m('div', { class: 'ui two column grid' }, [
          m('div', { class: 'column' }, [
            m('p', [
              m('div', { class: 'ui label' }, l('CONTACT_DETAILS')),
              m('div', module.model.fulladdress(f))
            ])
          ]),
          m('div', { class: 'column' }, [
            m('p', [
              gcs.multiBox(f.tels, l('TELS'), gcs.format.tels),
              gcs.multiBox(f.mails, l('MAILS'), gcs.format.mails),
              gcs.multiBox(f.www, l('WWW'), gcs.format.www)
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
