(function () {
  var widgets = golem.widgets.common;
  var contact = golem.module.contact;
  contact.component.remove = {
    controller: function () {
      var l = golem.utils.locale;
      var key = m.route.param('contactId');
      m.startComputation();
      golem.model.db.get(key, (function (err, res) {
        this.contact = res;
        document.title = golem.model.title(l('CONTACTS_REMOVE') +
          contact.model.fullname(this.contact));
        this.removeModalCtrl = new widgets.modal.controller({
          active: true,
          title: l('SURE'),
          content: l('CONTACTS_REMOVE_CONFIRM_MSG'),
          acceptFn: (function () {
            golem.model.db.remove(this.contact, function (err, res) {
              m.route('/contact/list');
            });
          }).bind(this),
          cancelFn: (function () {
            this.removeModalCtrl.toggle();
            m.route('/contact/list');
          }).bind(this)
        });
        m.endComputation();
      }).bind(this));
    },
    view: function (ctrl) {
      return m('section', { class: 'twelve wide column' },
        new widgets.modal.view(ctrl.removeModalCtrl)
      );
    }
  };
}).call(this);
