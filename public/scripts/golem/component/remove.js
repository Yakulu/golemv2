(function () {
  var l = golem.config.locale;
  var widgets = golem.widgets.common;
  golem.component.remove = function (props) {
    if (!props.acceptFn) {
      props.acceptFn = function (item) {
        golem.model.db.remove(item, function (err, res) {
          if (err) {
            golem.notifications.helpers.errorUnexpected({ body: err });
          } else {
            golem.notifications.helpers.success({ body: l.SUCCESS_DELETE });
          }
          m.route(props.route);
        });
      };
    }
    return {
      controller: function () {
        var me = this;
        var key = m.route.param(props.key);
        m.startComputation();
        golem.model.db.get(key, function (err, res) {
          if (err) {
            golem.notifications.helpers.error({ body: l.ERROR_RECORD_NOT_FOUND });
          } else {
            me.item = res;
            document.title = golem.utils.title(l.CONTACTS_REMOVE +
              props.nameFn(me.item))
            me.removeModalCtrl = new widgets.modal.controller({
              active: true,
              title: l.SURE,
              content: l[props.confirm],
              acceptFn: props.acceptFn.bind(me, me.item),
              cancelFn: function () {
                me.removeModalCtrl.toggle();
                m.route(props.route);
              }
            });
          }
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
