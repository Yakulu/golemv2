(function () {
  var fmodule = golem.module.family;
  var wform = golem.widgets.form;
  fmodule.component.form = {
    controller: function () {
      var l = golem.utils.locale;
      var mi = fmodule.data.menuItems;
      golem.menus.secondary.items = [ mi.list, mi.add ];
      var key = m.route.param('familyId');
      var main = (function () {
        golem.model.db.get(key, (function (err, res) {
          this.family = res;
          if (!this.family) {
            this.add = true;
            this.family = fmodule.model.create();
          } else {
            this.add = false;
          }
          this.telsWidget = golem.component.form.telsWidget(fmodule, this.family);
          this.mailsWidget = golem.component.form.mailsWidget(fmodule, this.family);
          this.wwwWidget = golem.component.form.wwwWidget(this.family);
          if (this.add) {
            document.title = golem.model.title(l('FAMILIES_NEW'));
          } else {
            document.title = golem.model.title(l('CONTACTS_EDIT') +
              this.family.lastname);
            ['show', 'edit', 'remove'].forEach((function (v) {
              mi[v].url = mi[v].baseUrl + '/' + this.family._id;
            }).bind(this));
            golem.menus.secondary.items.splice(2, 0,
              mi.show, mi.edit, mi.remove);
          }
          m.endComputation();
        }).bind(this));
      }).bind(this);
      m.startComputation();
      golem.model.getLabels('tels', golem.model.getLabels.bind(null, 'mails', main));
      this.submit = (function (e) {
        golem.component.form.submit(e, this.family, '/family/list');
      }).bind(this);
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var f = ctrl.family;
      var form = golem.widgets.form;
      var h2 = ctrl.add ? l('FAMILIES_NEW') : l('CONTACTS_EDIT') + ' ' + f.lastname;
      var mainContent = m('section', { class: 'ui piled segment' }, [
        m('h2', h2),
        m('form', {
          id: 'family-form',
          class: 'ui small form',
          onsubmit: ctrl.submit.bind(ctrl) }, [
            m('div', { class: 'field' }, [
              form.textHelper({
                name: 'lastname',
                label: l('LASTNAME'),
                minlength: 2,
                maxlength: 100,
                required: true,
                value: f.lastname,
                onchange: m.withAttr('value',
                  function (v) { f.lastname = v; })
              })
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
            m('div', { class: 'field' }, new form.multiFieldWidget.view(ctrl.wwwWidget)),
            m('div', { class: 'field' }, [
              m('label', { for: 'note' }, l('NOTE')),
              m('textarea', {
                  name: 'note',
                  onchange: m.withAttr('value',
                    function (v) { f.note = v; })
                }, f.note)
            ]),
            m('input', {
                id: 'family-submit',
                class:'ui teal submit button',
                type: 'submit',
                form: 'family-form',
                value: ctrl.add ? l('SAVE') : l('UPDATE')
            }),
            m('button', {
                name: 'cancel',
                class: 'ui button',
                type: 'button',
                onclick: function () { 
                  window.location.hash = '#/family/list';
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
              document.getElementById('family-submit').click();
            }
          }),
          m('div', {
            role: 'button',
          class: 'ui fluid button',
          onclick: function (e) { window.location = '#/family/list'; }
          }, l('CANCEL'))
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
