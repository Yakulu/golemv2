(function () {
  var module = golem.module.member;
  var wform = golem.widgets.form;
  module.component.form = {
    controller: function () {
      var l = golem.utils.locale;
      var mi = module.data.menuItems;
      golem.menus.secondary.items = [ mi.list, mi.add ];
      m.startComputation();
			var newMember = (function () {
			  this.add = true;
				this.member = module.model.create({});
			}).bind(this);
			var initController = (function () {
				this.minorExpanded = false;
				this.telsWidget = golem.component.form.telsWidget(module, this.member);
				this.mailsWidget = golem.component.form.mailsWidget(module, this.member);
				this.wwwWidget = golem.component.form.wwwWidget(this.member);
				this.tagWidget = golem.component.form.tagWidget(module, this.member.tags);
				this.skillWidget = new golem.widgets.form.tagWidget.controller({
					name: 'skills',
					label: l('SKILLS'),
					placeholder: l('SKILLS_NEW'),
					content: l('INFO_FORM_SKILLS'),
					size: 25,
					tags: module.data.skills.map(function (skill) { return skill.key[1]; }),
					current: this.member.skills
				});
				if (this.add) {
					document.title = golem.model.title(l('MEMBERS_NEW'));
				} else {
					document.title = golem.model.title(l('CONTACTS_EDIT') +
						module.model.fullname(this.member));
					['show', 'edit', 'remove'].forEach((function (v) {
						mi[v].url = mi[v].baseUrl + '/' + this.member._id;
					}).bind(this));
					golem.menus.secondary.items.splice(2, 0,
						mi.show, mi.edit, mi.remove);
				}
				this.familyFromMember = m.prop(true); // TMP : avoiding family form
				m.endComputation();
			}).bind(this);
      var key = m.route.param('memberId');
			/* TMP: Family OFF
      this.familyFromMember = m.prop(false);
      this.affectFamily = m.prop(false);
      this.family = m.prop(null);
      this.getFamilies = (function () {
        this.affectFamily(true);
        this.familyList = new golem.module.family.component.list.controller(true, this);
        m.startComputation();
        golem.model.db.query(
          'all/bySchema',
          {
            startkey: ['family'],
            endkey: ['family', {}],
            include_docs: true
          }, (function (err, res) {
            this.families = res.rows;
            m.endComputation(); 
          }).bind(this)
        );
      }).bind(this);*/
			var main = (function () {
				if (!key) {
					newMember();
					initController(); 
				} else {
					golem.model.db.get(key, (function (err, res) {
						this.member = res;
						if (!this.member) { newMember(); }
						initController();
							//this.familyFromMember(false);
					}).bind(this));
				}
			}).bind(this);
      golem.model.getLabels('tels',
        golem.model.getLabels.bind(null, 'mails',
          module.data.getTags.bind(this,
            module.data.getSkills.bind(this, main))));
      this.submit = (function (e) {
        golem.component.form.submit(e, this.member, '/member/list');
      }).bind(this);
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var f = ctrl.member;
      var form = golem.widgets.form;
      var h2 = ctrl.add ? l('MEMBERS_NEW') : l('CONTACTS_EDIT') + ' ' + module.model.fullname(f);
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
            m('div', { class: 'two fields' }, [
              form.textHelper({
                name: 'lastname',
                label: l('LASTNAME'),
                minlength: 2,
                maxlength: 100,
                required: true,
                value: f.lastname,
                onchange: m.withAttr('value',
                  function (v) { f.lastname = v; })
              }),
              form.textHelper({
                name: 'firstname',
                label: l('FIRSTNAME'),
                minlength: 2,
                maxlength: 100,
                required: true,
                value: f.firstname,
                onchange: m.withAttr('value',
                function (v) { f.firstname = v; })
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
                onchange: m.withAttr('value',
                  function (v) { f.postalCode = v; })
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
