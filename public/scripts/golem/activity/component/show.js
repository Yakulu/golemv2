(function () {
  var module = golem.module.activity;
  module.component.show = {
    controller: function () {
      var l = golem.utils.locale;
      var key = m.route.param('activityId');
      m.startComputation();
      golem.model.db.get(key, (function (err, res) {
        this.activity = res;
        document.title = golem.model.title(l('DETAILS')) +
          this.activity.label;
        var mi = module.data.menuItems;
        ['show', 'edit', 'remove'].forEach((function (v) {
          mi[v].url = mi[v].baseUrl + '/' + this.activity._id;
        }).bind(this));
        golem.menus.secondary.items = [
          mi.list, mi.add, mi.show, mi.edit, mi.remove
        ];
        golem.model.getMembersFromActivity(this.activity._id, (function (err, res) {
          this.members = res.rows;
          m.endComputation();
        }).bind(this));
      }).bind(this));
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var a = ctrl.activity;
      var mainContent = m('section', { class: 'ui piled segment' }, [
        m('h2', a.label),
        m('div', { class: 'ui horizontal list' }, [
          m('div.item', [
            m('div.content', [
              m('div.header', l('CODE')),
              m('div.description', a.code)
            ])
          ]),
          m('div.item', [
            m('div.content', [
              m('div.header', l('TIMESLOT')),
              m('div.description', a.timeSlot)
            ])
          ]),
          m('div.item', [
            m('div.content', [
              m('div.header', l('MONITOR')),
              m('div.description', a.monitor)
            ])
          ]),
          m('div.item', [
            m('div.content', [
              m('div.header', l('PLACES')),
              m('div.description', a.places)
            ])
          ]),
          m('div.item', [
            m('div.content', [
              m('div.header', l('PLACES_TAKEN')),
              m('div.description', ctrl.members.length)
            ])
          ]),
          m('div.item', [
            m('div.content', [
              m('div.header', l('PLACES_REMAIN')),
              m('div.description', (a.places - ctrl.members.length))
            ])
          ])
        ]),
        m('h3', l('ACTIVITIES_MEMBERS')),
        m('ul', { class: 'ui list' }, ctrl.members.map(function (i) {
          var fullname = golem.module.member.model.fullname(i.doc);
          return m('li', [
            m('a', { href: '#/member/show/' + i.doc._id }, fullname)
          ]);
        }))
      ]);
      return [
        m('section', { class: 'sixteen wide column' }, [
          new golem.menus.secondary.view(), mainContent
        ])
      ];
    }
  };
}).call(this);
