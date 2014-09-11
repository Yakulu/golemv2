(function () {
  var module = golem.module.activity;
  var wform = golem.widgets.form;
  module.component.form = {
    controller: function () {
      var l = golem.utils.locale;
      var mi = module.data.menuItems;
      golem.menus.secondary.items = [ mi.list, mi.add ];
      var newActivity = (function () {
        this.activity = module.model.create({});
        this.add = true;
        document.title = golem.model.title(l('ACTIVITIES_NEW'));
      }).bind(this);
      var key = m.route.param('activityId');
      if (!key) {
        newActivity(); 
      } else {
        m.startComputation();
        golem.model.db.get(key, (function (err, res) {
          this.activity = res;
          if (!this.activity) {
            newMember(); 
          } else {
            document.title = golem.model.title(l('CONTACTS_EDIT') + this.activity.label);
            ['show', 'edit', 'remove'].forEach((function (v) {
              mi[v].url = mi[v].baseUrl + '/' + this.activity._id;
            }).bind(this));
            golem.menus.secondary.items.splice(2, 0, mi.show, mi.edit, mi.remove);
          }
          m.endComputation();
        }).bind(this));
      }
      this.submit = golem.component.form.submit.bind(this, 'activity', '/activity/list');
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var a = ctrl.activity;
      var form = golem.widgets.form;
      var h2 = ctrl.add ? l('ACTIVITIES_NEW') : l('CONTACTS_EDIT') + ' ' + a.label;

      var mainContent = m('section', { class: 'ui piled segment'}, [
        m('h2', h2),
        m('form', {
          id: 'activity-form',
          class: 'ui small form',
          onsubmit: ctrl.submit.bind(ctrl)
        }, [
          m('div', { class:'fields' }, [
            form.textHelper({
              cls: 'eight wide field small input',
              name: 'label',
              label: l('LABEL'),
              minlength: 2,
              maxlength: 100,
              required: true,
              value: a.label,
              validationMsg: l('LASTNAME_VALIDATION_MSG'),
              validationCallback: function (e) { a.label = e.target.value; }
            }),
            form.textHelper({
              cls: 'four wide field small input',
              name: 'code',
              label: l('CODE'),
              minlength: 2,
              maxlength: 30,
              value: a.code,
              onchange: m.withAttr('value', function (v) { a.code = v; })
            }),
            m('div', { class: 'four wide field small input' }, [
              m('label', { for: 'places'}, l('PLACES')),
              m('input', {
                id: 'places',
                name: 'places',
                type: 'number',
                min: 0,
                max: 10000,
                step: 1,
                value: a.places,
                oninput: m.withAttr('value', function (v) {
                  // Ensure this is a number and it's not under 0
                  v = parseInt(v);
                  if (isNaN(v)) {
                    a.places = null;
                  } else {
                    a.places = (v < 0) ? null: v;
                  }
                })
              })
            ])
          ]),
          m('div', { class:'fields' }, [
            form.textHelper({
              cls: 'ten wide field small input',
              name: 'timeSlot',
              label: l('TIMESLOT'),
              minlength: 2,
              maxlength: 100,
              value: a.timeSlot,
              onchange: m.withAttr('value', function (v) { a.timeSlot = v; })
            }),
            form.textHelper({
              cls: 'six wide field small input',
              name: 'monitor',
              label: l('MONITOR'),
              minlength: 2,
              maxlength: 50,
              value: a.monitor,
              onchange: m.withAttr('value', function (v) { a.monitor = v; })
            })
          ]),
          m('div.field', [
            m('label', { for: 'note' }, l('NOTE')),
            m('textarea', {
                name: 'note',
                value: a.note,
                onchange: m.withAttr('value', function (v) { a.note = v; }) 
            }, a.note)
          ]),
            m('input', {
                id: 'activity-submit',
                class:'ui teal submit button',
                type: 'submit',
                form: 'activity-form',
                value: ctrl.add ? l('SAVE') : l('UPDATE')
            }),
            m('button', {
                name: 'cancel',
                class: 'ui button',
                type: 'button',
                onclick: function () { 
                  window.location.hash = '#/activity/list';
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
              document.getElementById('activity-submit').click();
            }
          }),
          m('div', {
            role: 'button',
          class: 'ui fluid button',
          onclick: function (e) { window.location = '#/activity/list'; }
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
