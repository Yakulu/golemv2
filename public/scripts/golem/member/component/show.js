(function () {
  var module = golem.module.member;
  module.component.show = {
    controller: function () {
      var me = this;
      var l = golem.utils.locale;
      var key = m.route.param('memberId');
      var initController = function () {
        document.title = golem.model.title(l('DETAILS') +
          module.model.fullname(me.member));
        var mi = module.data.menuItems;
        ['show', 'edit', 'remove'].forEach(function (v) {
          mi[v].url = mi[v].baseUrl + '/' + me.member._id;
        });
        golem.menus.secondary.items = [
          mi.list, mi.add, mi.show, mi.edit, mi.remove
        ];
        m.endComputation();
      };
      m.startComputation();
      golem.model.db.get(key, function (err, res) {
        me.member = res;
        if (me.member.activities.length > 0) {
          golem.model.db.allDocs({ keys: me.member.activities, include_docs: true }, function (err, res) {
            me.selectedActivities = res.rows.map(function (r) {
              return r.doc;
            });
            initController();
          });
        } else {
          me.selectedActivities = null;
          initController();
        }
      });
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var f = ctrl.member;
      var gcs = golem.component.show;
			var civilityContent = (function () {
				var items = [];
				if (f.gender) {
					var genderLocale = (f.gender === 'm') ? l('GENDER_MALE') : l('GENDER_FEMALE');
					var li = m('li.item', l('GENDER') + ' ' + genderLocale.toLowerCase());
					items.push(li);
				}
				if (f.birthday) { 
					items.push(m('li.item', l('BORN') + moment(f.birthday).format('L')));
				}
				if (f.nationality) {
					items.push(m('li.item', l('NATIONALITY') + ' ' +  f.nationality));
				}
				if (f.profession) { items.push(m('li.item', f.profession)); }
				return items;
			}).call(this);
			var columnLeftContent = [
				m('p', [
					m('div', { class: 'ui label purple' }, l('CIVILITY')),
					m('ul', { class: 'ui bulleted list' }, civilityContent)
				]),
				m('p', [
					m('div', { class: 'ui label teal' }, l('CONTACT_DETAILS')),
					m('div', module.model.fulladdress(f))
				])
			];
			if (f.guardianLastname) {
				var yesNo = function (bool) { return bool ? l('YES') : l('NO'); }
				var minorContent = m('p', [
					m('div', { class: 'ui label green' }, l('MINOR')),
					m('p', l('CHILD_GUARDIAN') + ': ' + f.guardianLastname + ' ' + f.guardianFirstname),
					m('div', l('AUTHORIZATIONS')),
					m('ul', { class: 'ui bulleted list' }, [
						m('li.item', l('ACTIVITIES_PARTICIPATION') + ': ' + yesNo(f.authorizations.activities)),
						m('li.item', l('AUTHORIZATIONS_PHOTOS') + ': ' + yesNo(f.authorizations.photos))
					])
				]);
				columnLeftContent.push(minorContent);
			}
			var communication = function () {
				var fcm = f.communicationModes;
				if (f.tels.length === 0 && f.mails.length === 0) { return ''; }
			  var content = l('COMMUNICATION_MODES_ACCEPTANCE') + ':'; 
				if (!fcm.mail && !fcm.tel) {
					content += ' ' + l('NONE');
				} else {
					if (fcm.mail) { content += ' ' + l('MAIL'); }
					if (fcm.tel) { content += ' ' + l('TEL'); }
				}
				return content;
			};
      var selectedActivities = function () {
        if (!ctrl.selectedActivities) { return l('NONE_F'); }
        return m('ul', { class: 'ui list' },
          ctrl.selectedActivities.map(function (a) {
            return m('li', [
              m('a', { href: '#/activity/show/' + a._id }, a.label) 
            ]);
          })
        );
      };
      var mainContent = m('section', { class: 'ui piled segment' }, [
        m('div', { class: 'ui floated right basic segment' }, [
          m('p',
						(function () {
							var tagsItems = f.tags.map(function (tag) {
								return m('span', {
										class: 'ui small teal label golem-tag',
										title: l('MEMBERS_BY_TAGS'),
										//config: m.route
									}, [
									m('i', { class: 'tag icon' }),
									tag
								]);
							});
							if (tagsItems.length > 0) {
								tagsItems.unshift(m('span', l('MENU_TAGS') + ' '));
							}
							return tagsItems;
						}).call(this)
					),
					m('p',
						(function () { 
							var skillsItems = f.skills.map(function (skill) {
								return m('span', {
										class: 'ui small blue label golem-tag',
										title: l('MEMBERS_BY_SKILLS'),
										//config: m.route
									}, [
									skill
								]);
							});
							if (skillsItems.length > 0) {
								skillsItems.unshift(m('span', l('SKILLS') + ' '));
							}
							return skillsItems;
						}).call(this)
					)
				]),
        m('h2', [
          m('span', module.model.fullname(f)),
          m('span', f.number ? ' (' + f.number + ')' : '')
        ]),
        m('p', { class: 'ui basic segment' },  f.note), //m.trust(f.note)),
        m('div', { class: 'ui two column grid' }, [
          m('div', { class: 'column' }, columnLeftContent),
          m('div', { class: 'column' }, [
            m('p', [
              m('div', { class: 'ui label red' }, l('MENU_ACTIVITIES')),
              m('p', selectedActivities()),
              m('div', { class: 'ui label purple' }, l('COMMUNICATION_MODES')),
              m('p', communication()),
              gcs.multiBox(f.tels, l('TELS'), gcs.format.tels),
              gcs.multiBox(f.mails, l('MAILS'), gcs.format.mails)
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
