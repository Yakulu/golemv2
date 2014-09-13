(function () {
  var module = golem.module.activity;
  module.component.list = {
    controller: function () {
      var me = this;
      var l = golem.config.locale;
      var mi = module.data.menuItems;
      golem.menus.secondary.items = [ mi.list, mi.add ];
      document.title = golem.utils.title(l.ACTIVITIES_LIST);
      me.items = [];
      me.sort = function (e) {
        golem.component.list.sort(e, me.items);
      };
      me.search = function (e) {
        me.filteredItems = golem.component.list.search(e, me.items);
      };
      var callback = function (err, results) {
        if (err) {
          golem.notifications.helpers.errorUnexpected({ body: err });
          me.items = [];
          m.endComputation();
        } else {
          me.items = results.rows;
          golem.model.getMembersFromActivity(null, function (err, res) {
            if (err) {
              golem.notifications.helpers.errorUnexpected({ body: err });
            } else {
              me.takenPlacesByActivity = {};
              for (var i = 0, l = res.rows.length; i < l; i++) {
                var aId = res.rows[i].key[0];
                if (!me.takenPlacesByActivity[aId]) {
                  me.takenPlacesByActivity[aId] = 1;
                } else {
                  me.takenPlacesByActivity[aId] += 1;
                }
              }
            }
            m.endComputation();
          });
        }
      };
      var getActivities = function () {
        m.startComputation();
        golem.model.getBySchema('activity', callback);
			};
      getActivities();
    },
    view: function (ctrl) {
      var l = golem.config.locale;
      var placesDom = function (i) {
        var color = 'inherit';
        if (i.places) {
          var distance = i.places - ctrl.takenPlacesByActivity[i._id];
          if (distance <= 0) { // Red
            color = 'red';
          } else {
            if (distance < 5) { // Orange
              color = 'orange';
            } else { // Green
              color = 'green';
            }
          }
        }
        return m('span',
          { style: { color: color } },
          ctrl.takenPlacesByActivity[i._id]);
      };
      var itemDom = function (i) {
        i = i.doc;
        return m('tr', [
          m('td', i.label),
          m('td', i.code),
          m('td', i.timeSlot),
          m('td', i.monitor),
          m('td', i.places),
          m('td', placesDom(i)),
          m('td', { class: 'actions' }, [
            m('a', { href: '#/activity/show/' + i._id, title: l.VIEW }, [
              m('i', { class: 'unhide icon' })
            ]),
            m('a', { href: '#/activity/edit/' + i._id, title: l.EDIT }, [
              m('i', { class: 'edit icon' })
            ]),
            m('a', { href: '#/activity/remove/' + i._id, title: l.DELETE }, [
              m('i', { class: 'remove icon' })
            ])
          ])
        ]);
      };
      var gwf = golem.widgets.form;
      var mainContent = m('table', { class: 'ui basic table' }, [
        m('thead', [
          m('tr', [
            gwf.sortTableHeaderHelper({ ctrl: ctrl, field: 'label' }),
            gwf.sortTableHeaderHelper({ ctrl: ctrl, field: 'code' }),
            m('th', l.TIMESLOT),
            m('th', l.MONITOR),
            gwf.sortTableHeaderHelper({ ctrl: ctrl, field: 'places' }),
            m('th', l.PLACES_TAKEN),
            m('th', { width: '10%' }, l.ACTIONS)
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
