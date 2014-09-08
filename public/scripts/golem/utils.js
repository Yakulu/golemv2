(function () {
  golem.utils = {
    locale: function (str) { return golem.config.locale[str]; },
    sendNotification: function (title, options, callback) {
      var _send = function () {
        var notif = new Notify(title, options);
        notif.show();
        callback();
      };
      var _alert = function () {
        alert(title + ' : ' + options.body); 
        callback();
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
  };
}).call(this);
