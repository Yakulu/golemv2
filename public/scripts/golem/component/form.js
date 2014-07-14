(function () {
  // Abstraction
  var l = golem.utils.locale;
  golem.component.form = {
    telsWidget: function (module, item) {
      return new golem.widgets.form.multiFieldWidget.controller({
        label: l('TELS'),
        name: 'tels',
        maxlength: 10,
        size: 15,
        radioField: true,
        labelField: true,
        labels: golem.model.labels.tels,
        placeholder: l('TEL_PLACEHOLDER'),
        content: l('INFO_FORM_TELS'),
        current: item.tels
      });
    },
    mailsWidget: function (module, item) {
      return new golem.widgets.form.multiFieldWidget.controller({
        type: 'email',
        label: l('MAILS'),
        name: 'mails',
        size: 25,
        radioField: true,
        labelField: true,
        labels: golem.model.labels.mails,
        placeholder: l('MAIL_PLACEHOLDER'),
        content: l('INFO_FORM_MAILS'),
        current: item.mails
      });
    },
    wwwWidget: function (item) {
      return new golem.widgets.form.multiFieldWidget.controller({
        type: 'url',
        label: l('WWW'),
        name: 'www',
        placeholder: l('WWW_PLACEHOLDER'),
        content: l('INFO_FORM_WWW'),
        current: item.www
      });
    },
    submit: function (e, item, route) {
      e.preventDefault();
      var _submit = function (verb) {
        golem.model.db[verb](item, function (err, res) {
          golem.utils.sendNotification(
            l('SUCCESS'),
            { body: l('SUCCESS_UPDATE') },
            m.route.bind(null, route)
          );
        });
      };
      var verb = item._id ? 'put' : 'post';
      _submit(verb);
    }
  };
}).call(this);
