(function () {
  golem.utils = {
    title: function (suffix) {
      return golem.config.locale.TITLE + ' - ' + suffix;
    },
    sendNotificationHTML5: function (title, options, callback) {
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
    sendNotification: function (config, callback) {
      var timeout = config.timeout;
      config.timeout = (timeout || (timeout === false)) ? timeout : 10;
      var gnm = golem.notifications.model;
      gnm.counter += 1;
      gnm.items[gnm.counter] = config;
      if (callback) { return callback(); }
    },
    handlePouchError: function (err, res, callbackSuccess, callbackAlways) {
      if (err) {
        golem.notifications.helpers.errorUnexpected({ body: err });
      } else {
        callbackSuccess(err, res);
      }
      if (callbackAlways) { callbackAlways(); }
    }
  };
}).call(this);
