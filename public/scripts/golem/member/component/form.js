(function () {
  var module = golem.module.member;
  var wform = golem.widgets.form;
  module.component.form = {
    controller: function () {
      var me = this;
      var l = golem.utils.locale;
      var mi = module.data.menuItems;
      golem.menus.secondary.items = [ mi.list, mi.add ];
      m.startComputation();
			var newMember = function () {
			  me.add = true;
				me.member = module.model.create({});
			};
			var initController = function () {
        if (me.member.activities.length === 0) {
          me.selectedActivities = [];
        } else {
          me.selectedActivities = me.activities.filter(function (a) {
            return (me.member.activities.indexOf(a.id) !== -1);
          });
          me.selectedActivities = me.selectedActivities.map(function (a) {
              return golem.module.activity.model.fullLabel(a.doc);
          });
        }
				me.minorExpanded = false;
				me.telsWidget = golem.component.form.telsWidget(module, me.member);
				me.mailsWidget = golem.component.form.mailsWidget(module, me.member);
				me.tagWidget = golem.component.form.tagWidget(module, me.member.tags);
				me.skillWidget = new golem.widgets.form.tagWidget.controller({
					name: 'skills',
					label: l('SKILLS'),
					placeholder: l('SKILLS_NEW'),
					content: l('INFO_FORM_SKILLS'),
					size: 25,
					tags: module.data.skills.map(function (skill) { return skill.key[1]; }),
					current: me.member.skills
				});
        /*me.activitiesWidget = new golem.widgets.form.multiFieldWidget.controller({
          tagName: 'select',
          label: l('ACTIVITIES_CHOICE'),
          name: 'activities',
          content: l('INFO_FORM_ACTIVITIES'),
          current: me.member.activities
        });*/
				if (me.add) {
					document.title = golem.model.title(l('MEMBERS_NEW'));
				} else {
					document.title = golem.model.title(l('CONTACTS_EDIT') +
						module.model.fullname(me.member));
					['show', 'edit', 'remove'].forEach(function (v) {
						mi[v].url = mi[v].baseUrl + '/' + me.member._id;
					});
					golem.menus.secondary.items.splice(2, 0,
						mi.show, mi.edit, mi.remove);
				}
				me.familyFromMember = m.prop(true); // TMP : avoiding family form
				m.endComputation();
			};
      var key = m.route.param('memberId');
			/* TMP: Family OFF
      me.familyFromMember = m.prop(false);
      me.affectFamily = m.prop(false);
      me.family = m.prop(null);
      me.getFamilies = function () {
        me.affectFamily(true);
        me.familyList = new golem.module.family.component.list.controller(true, me);
        m.startComputation();
        golem.model.db.query(
          'all/bySchema',
          {
            startkey: ['family'],
            endkey: ['family', {}],
            include_docs: true
          }, function (err, res) {
            me.families = res.rows;
            m.endComputation(); 
          }
        );
      };*/
			var main = function () {
				if (!key) {
					newMember();
					initController(); 
				} else {
					golem.model.db.get(key, function (err, res) {
						me.member = res;
						if (!me.member) { newMember(); }
						initController();
							//me.familyFromMember(false);
					});
				}
			};
      golem.model.getBySchema('activity', function (err, res) {
        me.activities = res.rows;
        golem.model.getLabels('tels',
          golem.model.getLabels.bind(null, 'mails',
            module.data.getTags.bind(me,
              module.data.getSkills.bind(me, main))))
      });
      me.submit = golem.component.form.submit.bind(me, 'member', '/member/list');
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var f = ctrl.member;
      var form = golem.widgets.form;
      var h2 = ctrl.add ? l('MEMBERS_NEW') : l('CONTACTS_EDIT') + ' ' + module.model.fullname(f);
      var activitiesList = (function () {
        var content;
        if (f.activities.length === 0) {
          content = l('NONE_F');
        } else {
          content = ctrl.selectedActivities.join(', ');
        }
        return m('span', content);
      }).call(this);
      var initialContent = m('section', { class: 'ui piled segment' }, [
        m('p', l('MEMBERS_NEW_FAMILY_MSG')),
        m('button', {
          class: 'fluid ui button',
          onclick: ctrl.getFamilies
        }, l('MEMBERS_NEW_FAMILY_AFFECT')),
        m('button', {
          class: 'fluid ui button',
          onclick: function () { m.route('/family/add'); }
        }, l('MEMBERS_NEW_FAMILY_NEW')),
        m('button', {
          class: 'fluid ui button',
          onclick: ctrl.familyFromMember.bind(ctrl, true)
        }, l('MEMBERS_NEW_FAMILY_FROM'))
      ]);
      var familyDom = function (f) {
        return m('option', { value: f.doc._id },
          f.doc.lastname + golem.module.family.model.fulladdress(f.doc));
      };
      var familyContent = function () {
        return m('section', { class: 'ui piled segment' }, [
          m('h2', l('MEMBERS_NEW_FAMILY_AFFECT')),
          m('div', { class: 'ui grid' }, [
            new golem.module.family.component.list.view(ctrl.familyList)
          ])
        ]);
      };
      var formContent = m('section', { class: 'ui piled segment' }, [
        m('h2', h2),
        m('form', {
          id: 'member-form',
          class: 'ui small form',
          onsubmit: ctrl.submit.bind(ctrl) }, [
					  m('h3', { class: 'ui inverted center aligned purple header' }, l('CIVILITY')),
            m('div', { class: 'fields' }, [
              form.textHelper({
                cls: 'four wide field',
                name: 'number',
                label: l('MEMBER_NUMBER'),
                minlength: 1,
                maxlength: 20,
                value: f.number,
                onchange: m.withAttr('value',
                  function (v) { f.number = v; })
              }),
              form.textHelper({
                cls: 'six wide field',
                name: 'lastname',
                label: l('LASTNAME'),
                minlength: 2,
                maxlength: 100,
                required: true,
                value: f.lastname,
                validationMsg: l('LASTNAME_VALIDATION_MSG'),
                validationCallback: function (e) { f.lastname = e.target.value; }
              }),
              form.textHelper({
                cls: 'six wide field',
                name: 'firstname',
                label: l('FIRSTNAME'),
                minlength: 2,
                maxlength: 100,
                required: true,
                value: f.firstname,
                validationMsg: l('LASTNAME_VALIDATION_MSG'),
                validationCallback: function (e) { f.firstname = e.target.value; }
              }),
            ]),
            m('div', { class: 'fields' }, [
							m('div', { class: 'one wide field' }, l('GENDER')),
							m('div', { class: 'two wide field' }, [
								m('div', { class: 'ui radio checkbox' }, [
									m('input', {
										type: 'radio',
										name: 'gender',
										value: 'm',
										checked: (f.gender === 'm'),
										onchange: function (v) { f.gender = 'm'; }
									}),
									m('label', {
										onclick: function (v) { f.gender = 'm'; }
									},
										l('GENDER_MALE')),
								]),
							]),
							m('div', { class: 'two wide field' }, [
								m('div', { class: 'ui radio checkbox' }, [
									m('input', {
										type: 'radio',
										name: 'gender',
										value: 'f',
										checked: (f.gender === 'f'),
										onchange: function (v) { f.gender = 'f'; }
									}),
									m('label', {
										onclick: function (v) { f.gender = 'f'; }
									},
										l('GENDER_FEMALE')),
								]),
							]),
              form.textHelper({
								cls: 'three wide field',
							  name: 'birthday',
								label: l('BIRTHDAY'),
								placeholder: 'jj, mm, jjmm, jjmmaa, jj/mm/aaaa',
								pattern: '\\d{2}/\\d{2}/\\d{4}',
								value: f.birthday ? moment(f.birthday).format('L') : '',
								onchange: m.withAttr(
									'value',
									function (v) {
										if (!v) {
											f.birthday = null;
										} else {
											v = v.replace('/', '', 'g');
											var birthday;
											if (v && /^\d+$/.test(v)) {
												switch (v.length) {
													case 1:
														v = '0' + v;
													case 2:
														birthday = moment(v, 'DD');
														break;
													case 4:
														birthday = moment(v, 'DDMM');
														break;
													case 6:
														birthday = moment(v, 'DDMMYY');
														break;
													case 8:
														birthday = moment(v, 'DDMMYYYY');
														break;
												}
											}
											if (birthday && birthday.isValid()) {
												f.birthday = birthday.toString();
												// If the person is minor, expand the fields
												var isMinor = birthday.isAfter(moment().subtract(18, 'years'));
												if (isMinor) {
													ctrl.minorExpanded = true; 
													if (ctrl.add) {
														f.authorizations.activities = true;
														f.authorizations.photos = true;
													}
												}
											} else {
												f.birthday = null;
											}
										}
									}
								)
							}),
              form.textHelper({
								cls: 'four wide field',
							  name: 'nationality',
								label: l('NATIONALITY'),
								value: f.nationality,
								onchange: m.withAttr(
									'value',
									function (v) { f.nationality = v; }
								)
							}),
              form.textHelper({
								cls: 'four wide field',
							  name: 'profession',
								label: l('PROFESSION'),
								value: f.profession,
								onchange: m.withAttr(
									'value',
									function (v) { f.profession = v; }
								)
							})
            ]),
					  m('h3', { class: 'ui inverted center aligned teal header' }, l('CONTACT_DETAILS')),
            m('div', { class: 'three fields' }, [
              form.textHelper({
                name: 'address',
                label: l('ADDRESS'),
                value: f.address,
                onchange: m.withAttr('value',
                  function (v) { f.address = v; })
              }),
              form.textHelper({
                name: 'postalCode',
                label: l('POSTAL_CODE'),
                value: f.postalCode,
								maxlength: 5,
								pattern: '^\\d{5}$',
                validationMsg: l('POSTAL_CODE_VALIDATION_MSG'),
                validationCallback: function (e) { f.postalCode = e.target.value; }
              }),
              form.textHelper({
                name: 'city',
                label: l('CITY'),
                value: f.city,
                onchange: m.withAttr('value',
                  function (v) { f.city = v; })
              })
            ]),
            m('div', { class: 'ui two fields'}, [
              m('div', { class: 'field' }, [
								new form.multiFieldWidget.view(ctrl.telsWidget)
								]),
              m('div', { class: 'field' }, [
              new form.multiFieldWidget.view(ctrl.mailsWidget)
							])
            ]),
					  m('div', { class: 'three fields'}, [
								m('div', { class: 'field' }, l('COMMUNICATION_MODES')),
								m('div', { class: 'inline field', }, [
								  m('input', {
										type: 'checkbox',
										name: 'cmodes-mail',
										checked: f.communicationModes['mail'],
										onchange: m.withAttr('checked', function (c) { f.communicationModes['mail'] = c; })
									}),
									m('label', { for: 'cmodes-mail' }, l('MAIL'))
								]),
								m('div', { class: 'inline field', }, [
								  m('input', {
										type: 'checkbox',
										name: 'cmodes-tel',
										checked: f.communicationModes['tel'],
										onchange: m.withAttr('checked', function (c) { f.communicationModes['tel'] = c; })
									}),
									m('label', { for: 'cmodes-tel' }, l('TEL'))
								])
						]),
					  m('h3', { class: 'ui inverted center aligned green header' }, [
							m('span', [
								l('MINOR') + ' ',
								(function () {
									var iconCls = ctrl.minorExpanded ? 'icon circle up' : 'icon circle down';
									var icon =  m('i', {
										class: iconCls,
									  style: { cursor: 'pointer' },
										onclick: function () { ctrl.minorExpanded = !ctrl.minorExpanded; }
									});
									return icon;
								}).call(this)
							])
						]),
					  m('div', {
							class: 'fields',
							style: { display: ctrl.minorExpanded ? 'block' : 'none' }
						}, [
					    m('div', { class: 'two wide field' }, l('CHILD_GUARDIAN')),
              form.textHelper({
								cls: 'three wide field',
                name: 'guardian-lastname',
                label: l('LASTNAME'),
                minlength: 2,
                maxlength: 100,
                value: f.guardianLastname,
                onchange: m.withAttr('value',
                  function (v) { f.guardianLastname = v; })
              }),
              form.textHelper({
								cls: 'three wide field',
                name: 'guardian-firstname',
                label: l('FIRSTNAME'),
                minlength: 2,
                maxlength: 100,
                value: f.guardianFirstname,
                onchange: m.withAttr('value',
                function (v) { f.guardianFirstname = v; })
              }),
					    m('div', { class: 'two wide field' }, l('AUTHORIZATIONS')),
					    m('div', { class: 'three wide inline field' }, [
								m('input', {
									type: 'checkbox',
									name: 'authorizations-activities',
									checked: f.authorizations['activities'],
									onchange: m.withAttr('checked', function (c) { f.authorizations['activities'] = c; })
								}),
								m('label', { for: 'authorizations-activities' }, l('ACTIVITIES_PARTICIPATION'))
							]),
					    m('div', { class: 'three wide inline field' }, [
								m('input', {
									type: 'checkbox',
									name: 'authorizations-photos',
									checked: f.authorizations['photos'],
									onchange: m.withAttr('checked', function (c) { f.authorizations['photos'] = c; })
								}),
								m('label', { for: 'authorizations-photos' }, l('AUTHORIZATIONS_PHOTOS'))
							])
						]),
					  m('h3', { class: 'ui inverted center aligned blue header' }, l('COMPLEMENTARY')),
            m('div', { class: 'two fields' }, [
              //new form.multiFieldWidget.view(ctrl.wwwWidget),
              new form.tagWidget.view(ctrl.tagWidget),
              new form.tagWidget.view(ctrl.skillWidget)
            ]),
            m('div', { class: 'field' }, [
              m('label', { for: 'note' }, l('NOTE')),
              m('textarea', {
                  name: 'note',
									value: f.note,
                  onchange: m.withAttr('value',
                    function (v) { f.note = v; })
                }, f.note)
            ]),
					  m('h3', { class: 'ui inverted center aligned red header' }, l('MENU_ACTIVITIES')),
            m('div', { class: 'ui grid' }, [
              m('div', { class: 'eight wide column' }, [
                m('div.field', [
                  // TODO : multiFieldWidget refactoring to allow select and others...
                  m('select', {
                    name: 'activities',
                    multiple: true,
                    size: ctrl.activities.length + 1,
                    onchange: function (e) {
                      var selectedActivities = [];
                      ctrl.selectedActivities = [];
                      for (var i = 0, l = e.target.options.length; i < l; i++) {
                        var option = e.target.options[i];
                        if (option.selected) {
                          selectedActivities.push(option.value); 
                          ctrl.selectedActivities.push(option.text); 
                        }
                      }
                      f.activities = selectedActivities;
                    }
                  }, [
                    m('optgroup', { label: l('MENU_ACTIVITIES') }, [
                      ctrl.activities.map(function (a) {
                        return m('option', {
                          value: a.id,
                          label: golem.module.activity.model.fullLabel(a.doc),
                          selected: (f.activities.indexOf(a.id) !== -1)
                        }, golem.module.activity.model.fullLabel(a.doc));
                      })
                    ])
                  ]),
                m('p', [
                  m('span', l('ACTIVITIES_SELECTED')),
                  activitiesList
                ])
              ])
            ]),
            m('div', { class: 'eight wide column' }, [
              m('div', { class: 'ui purple inverted segment' }, [
                m('h3', [
                  m('i', { class: 'info icon' }),
                  m('span', l('HELP'))
                ]),
                m('p', m.trust(l('ACTIVITIES_HELP')))
              ])
            ])
          ]),
          m('input', {
              id: 'member-submit',
              class:'ui teal submit button',
              type: 'submit',
              form: 'member-form',
              value: ctrl.add ? l('SAVE') : l('UPDATE')
          }),
          m('button', {
              name: 'cancel',
              class: 'ui button',
              type: 'button',
              onclick: function () { 
                window.location.hash = '#/member/list';
              }
            }, l('CANCEL'))
        ])
      ]);
      var contextMenuContent = m('nav', [
        m('menu', { class: 'ui buttons fixed-right' }, [
          m('input', {
            class: 'ui fluid teal submit button',
            type: 'submit',
            value: ctrl.add ? l('SAVE') : l('UPDATE'),
            // FIXME : here's a hack, to fix properly
            onclick: function () {
              document.getElementById('member-submit').click();
            }
          }),
          m('div', {
            role: 'button',
          class: 'ui fluid button',
          onclick: function (e) { window.location = '#/member/list'; }
          }, l('CANCEL'))
        ])
      ]);
      var mainContent;
      // Form if editing, if family will be created form members details or
      // if a family has already been affected
      var isForm = (!ctrl.add || ctrl.familyFromMember() || !!ctrl.family());
      if (isForm) {
        mainContent = formContent;
      } else {
        if (ctrl.affectFamily()) {
          // We have to select and affect a family
          mainContent = familyContent();
        } else {
          // Home choice
          mainContent = initialContent;
        }
      }
      return [
        m('section', { class: 'twelve wide column' }, [
          new golem.menus.secondary.view(), mainContent
        ]),
        m('section', { class: 'four wide column' }, isForm ? contextMenuContent : '')
      ];
    }
  };

}).call(this);
