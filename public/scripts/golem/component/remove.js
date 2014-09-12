(function () {
  var l = golem.utils.locale;
  var widgets = golem.widgets.common;
  golem.component.remove = function (props) {
    return {
      controller: function () {
        var me = this;
        var key = m.route.param(props.key);
        m.startComputation();
        golem.model.db.get(key, function (err, res) {
          me.item = res;
          document.title = golem.model.title(l('CONTACTS_REMOVE') +
            props.nameFn(me.item))
          me.removeModalCtrl = new widgets.modal.controller({
            active: true,
            title: l('SURE'),
            content: l(props.confirm),
            acceptFn: function () {
              golem.model.db.remove(me.item, function (err, res) {
                m.route(props.route);
              });
            },
            cancelFn: function () {
              me.removeModalCtrl.toggle();
              m.route(props.route);
            }
          });
          m.endComputation();
        });
      },
      view: function (ctrl) {
        return m('section', { class: 'twelve wide column' },
          new widgets.modal.view(ctrl.removeModalCtrl)
        );
      }
    };
  };
}).call(this);
