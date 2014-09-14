// Generated by CoffeeScript 1.8.0
(function() {
  var l;

  l = golem.config.locale;

  golem.notifications = {
    helpers: {
      base: function(options, callback) {
        this.options = options;
        return golem.utils.sendNotification(this.options, callback);
      },
      success: function(options, callback) {
        if (options.title == null) {
          options.title = l.SUCCESS;
        }
        options.cls = 'success';
        options.icon = 'checkmark';
        return golem.notifications.helpers.base(options, callback);
      },
      info: function(options, callback) {
        if (options.title == null) {
          options.title = l.INFO;
        }
        options.cls = options.icon = 'info';
        return golem.notifications.helpers.base(options, callback);
      },
      warning: function(options, callback) {
        options.title = l.WARNING;
        options.cls = options.icon = 'warning';
        options.timeout = 15;
        return golem.notifications.helpers.base(options, callback);
      },
      error: function(options, callback) {
        options.title = l.ERROR;
        options.cls = 'error';
        options.icon = 'attention';
        options.timeout = false;
        return golem.notifications.helpers.base(options, callback);
      },
      errorUnexpected: function(options, callback) {
        options.body = "<em>" + options.body + "</em><br>" + l.ERROR_UNEXPECTED;
        return golem.notifications.helpers.error(options, callback);
      }
    },
    model: {
      items: {},
      counter: 0
    },
    controller: function() {
      var gnm;
      gnm = golem.notifications.model;
      this.toClose = {};
      this.close = (function(_this) {
        return function(id, from) {
          if (from && from !== 'timeout') {
            window.clearTimeout(_this.toClose[id]);
          }
          delete _this.toClose[id];
          return delete gnm.items[id];
        };
      })(this);
      this.delayClose = (function(_this) {
        return function(id, timeout) {
          if (timeout && !_this.toClose[id]) {
            return _this.toClose[id] = window.setTimeout(function() {
              _this.close(id, 'timeout');
              return m.redraw();
            }, timeout * 1000);
          }
        };
      })(this);
    },
    view: function(ctrl) {
      var gnm, keys;
      gnm = golem.notifications.model;
      keys = Object.keys(gnm.items).sort();
      return m('div', keys.map(function(id) {
        var closeFn, n, notifClass;
        n = gnm.items[id];
        ctrl.delayClose(id, n.timeout);
        closeFn = ctrl.close.bind(ctrl, id, n.timeout);
        notifClass = ['ui', 'floating', 'message', 'notification'];
        if (n.cls) {
          notifClass.push(n.cls);
        }
        if (n.icon) {
          notifClass.push('icon');
        }
        return m('div', {
          "class": notifClass.join(' '),
          onclick: n.click ? n.click : closeFn
        }, [
          n.icon ? m('i', {
            "class": n.icon + ' icon'
          }) : '', m('i', {
            "class": 'close icon',
            onclick: closeFn
          }), m('div.content', [m('div.header', n.title), m('p', m.trust(n.body))])
        ]);
      }));
    }
  };

}).call(this);

//# sourceMappingURL=notifications.js.map
