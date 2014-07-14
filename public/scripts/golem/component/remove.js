(function () {
  var l = golem.utils.locale;
  var widgets = golem.widgets.common;
  golem.component.remove = function (props) {
    return {
      controller: function () {
        var key = m.route.param(props.key);
        m.startComputation();
        golem.model.db.get(key, (function (err, res) {
          this.item = res;
          document.title = golem.model.title(l('CONTACTS_REMOVE') +
            props.nameFn(this.item))
          this.removeModalCtrl = new widgets.modal.controller({
            active: true,
            title: l('SURE'),
            content: l(props.confirm),
            acceptFn: (function () {
              golem.model.db.remove(this.item, function (err, res) {
                m.route(props.route);
              });
            }).bind(this),
            cancelFn: (function () {
              this.removeModalCtrl.toggle();
              m.route(props.route);
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
  };
}).call(this);
