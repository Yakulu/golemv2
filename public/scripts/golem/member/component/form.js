(function () {
  var module = golem.module.member;
  var wform = golem.widgets.form;
  module.component.form = {
    controller: function () {
      var l = golem.utils.locale;
      var mi = module.data.menuItems;
      golem.menus.secondary.items = [ mi.list, mi.add ];
      var key = m.route.param('memberId');
      this.member = module.model.create({});
      this.add = true;
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
      }).bind(this);
      var main = (function () {
        golem.model.db.get(key, (function (err, res) {
          this.member = res;
          if (!this.member) {
            this.add = true;
            this.familyFromMember(false);
            this.member = module.model.create({});
          } else {
            this.add = false;
            this.familyFromMember(true);
          }
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
          m.endComputation();
        }).bind(this));
      }).bind(this);
      m.startComputation();
      golem.model.getLabels('tels',
        golem.model.getLabels.bind(null, 'mails',
          module.data.getTags.bind(this,
            module.data.getSkills.bind(this, main))));
      this.submit = (function (e) {
        golem.component.form.submit(e, this.member, '/member/list');
      }).bind(this);
    },
    view: function (ctrl) {
      window.ctrl = ctrl;
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
            m('div', [
              new form.multiFieldWidget.view(ctrl.telsWidget),
              new form.multiFieldWidget.view(ctrl.mailsWidget)
            ]),
            m('div', { class: 'three fields' }, [
              new form.multiFieldWidget.view(ctrl.wwwWidget),
              new form.tagWidget.view(ctrl.tagWidget),
              new form.tagWidget.view(ctrl.skillWidget)
            ]),
            m('div', { class: 'field' }, [
              m('label', { for: 'note' }, l('NOTE')),
              m('textarea', {
                  name: 'note',
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
