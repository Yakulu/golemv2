(function () {
  var contact = golem.module.contact;
  var form = golem.widgets.form;
  contact.component.form = {
    controller: function () {
      // Init
      var l = golem.utils.locale;
      // Menus
      var cmi = contact.data.menuItems;
      golem.menus.secondary.items = [ cmi.list, cmi.add ];
      // Model
      var key = m.route.param('contactId');
      m.startComputation();
      var main = (function () {
        golem.model.db.get(key, (function (err, res) {
          this.contact = res;
          if (!this.contact) {
            this.add = true;
            this.contact = contact.model.create({
              firstname: '',
              lastname: ''
            });
          } else {
            this.add = false;
          }
          // Widgets
          this.telsWidget = new form.multiFieldWidget.controller({
            label: l('TELS'),
            name: 'tels',
            maxlength: 10,
            size: 15,
            radioField: true,
            labelField: true,
            labels: contact.data.labels.tels,
            placeholder: l('TEL_PLACEHOLDER'),
            content: l('INFO_FORM_TELS'),
            current: this.contact.tels
          });
          this.mailsWidget = new form.multiFieldWidget.controller({
            type: 'email',
            label: l('MAILS'),
            name: 'mails',
            size: 25,
            radioField: true,
            labelField: true,
            labels: contact.data.labels.mails,
            placeholder: l('MAIL_PLACEHOLDER'),
            content: l('INFO_FORM_MAILS'),
            current: this.contact.mails
          });
          this.wwwWidget = new form.multiFieldWidget.controller({
            type: 'url',
            label: l('WWW'),
            name: 'www',
            placeholder: l('WWW_PLACEHOLDER'),
            content: l('INFO_FORM_WWW'),
            current: this.contact.www
          });
          this.tagWidget = new form.tagWidget.controller({
            name: 'tags',
            label: l('MENU_TAGS'),
            placeholder: l('TAGS_PLACEHOLDER'),
            content: l('INFO_FORM_TAGS'),
            size: 25,
            tags: contact.data.tags.map(function (tag) { return tag.key[1]; }),
            current: this.contact.tags
          });
          // Add or edit
          if (this.add) {
            document.title = golem.model.title(l('CONTACTS_NEW'));
          } else {
            document.title = golem.model.title(l('CONTACTS_EDIT') +
              contact.model.fullname(this.contact));
            ['show', 'edit', 'remove'].forEach((function (v) {
              cmi[v].url = cmi[v].baseUrl + '/' + this.contact._id;
            }).bind(this));
            golem.menus.secondary.items.splice(2, 0,
              cmi.show, cmi.edit, cmi.remove);
          }
          m.endComputation();
        }).bind(this));
      }).bind(this);
      var cd = contact.data;
      cd.getTags(cd.getLabels.bind(null, 'tels', cd.getLabels.bind(null, 'mails', main)));
      // Methods
      this.submit = (function (e) {
        e.preventDefault();
        var _submit = (function (verb) {
          golem.model.db[verb](this.contact, function (err, res) {
            golem.utils.sendNotification(
              l('SUCCESS'),
              { body: l('SUCCESS_UPDATE') },
              m.route.bind(null, '/contact/list')
            );
          });
        }).bind(this);
        var verb = this.contact_id ? 'put' : 'post';
        _submit(verb);
      }).bind(this);
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var c = ctrl.contact;
      var h2 = ctrl.add ? l('CONTACTS_NEW') : l('CONTACTS_EDIT') + ' ' + contact.model.fullname(c);
      var mainContent = m('section', { class: 'ui piled segment' }, [
        m('h2', h2),
        m('form', {
          id: 'contact-form',
          class: 'ui small form',
          onsubmit: ctrl.submit.bind(ctrl) }, [
          m('div', { class: 'two fields' }, [
            form.textHelper({
              name: 'lastname',
              label: l('LASTNAME'),
              minlength: 2,
              maxlength: 100,
              required: true,
              value: c.lastname,
              onchange: m.withAttr('value',
                function (v) { c.lastname = v; })
            }),
            form.textHelper({
              name: 'firstname',
              label: l('FIRSTNAME'),
              minlength: 2,
              maxlength: 100,
              required: true,
              value: c.firstname,
              onchange: m.withAttr('value',
                function (v) { c.firstname = v; })
            })
          ]),
          m('div', { class: 'three fields' }, [
            form.textHelper({
              name: 'address',
              label: l('ADDRESS'),
              value: c.address,
              onchange: m.withAttr('value',
                function (v) { c.address = v; })
            }),
            form.textHelper({
              name: 'postalCode',
              label: l('POSTAL_CODE'),
              value: c.postalCode,
              onchange: m.withAttr('value',
                function (v) { c.postalCode = v; })
            }),
            form.textHelper({
              name: 'city',
              label: l('CITY'),
              value: c.city,
              onchange: m.withAttr('value',
                function (v) { c.city = v; })
            })
          ]),
          m('div', [
            new form.multiFieldWidget.view(ctrl.telsWidget),
            new form.multiFieldWidget.view(ctrl.mailsWidget)
          ]),
          m('div', { class: 'two fields' }, [
            new form.multiFieldWidget.view(ctrl.wwwWidget),
            new form.tagWidget.view(ctrl.tagWidget),
          ]),
          m('div', { class: 'field' }, [
            m('label', { for: 'note' }, l('NOTE')),
            m('textarea', {
                name: 'note',
                onchange: m.withAttr('value',
                  function (v) { c.note = v; })
              }, c.note)
          ]),
          m('input', {
              id: 'contact-submit',
              class:'ui teal submit button',
              type: 'submit',
              form: 'contact-form',
              value: ctrl.add ? l('SAVE') : l('UPDATE')
          }),
          m('button', {
              name: 'cancel',
              class: 'ui button',
              type: 'button',
              onclick: function () { 
                window.location.hash = '#/contact/list';
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
              document.getElementById('contact-submit').click();
            }
          }),
          m('div', {
            role: 'button',
          class: 'ui fluid button',
          onclick: function (e) { window.location = '#/contact/list'; }
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
