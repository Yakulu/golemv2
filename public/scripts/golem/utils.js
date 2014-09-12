(function () {
  golem.utils = {
    locale: function (str) { return golem.config.locale[str]; },
    sendNotification: function (title, options, callback) {
      options.timeout = options.timeout || 5;
      var _send = function () {
        var notif = new Notify(title, options);
        notif.show();
        if (callback) { callback(); }
      };
      var _alert = function () {
        alert(title + ' : ' + options.body); 
        if (callback) { callback(); }
      };
      if (!Notify.isSupported) {
        _alert();
      } else {
        if (Notify.needsPermission) {
          Notify.requestPermission(_send, _alert);
        } else {
          _send();
        }
      }
    },
    sendNotificationNG: function (config) {
      config.timeout = config.timeout || 10;
      golem.notifications.model.items.unshift(config);
      m.redraw(); // FIXME with huge rearchitecturing hierarchical MVC or simply inversing items ? -> oui
    }
  };
}).call(this);
