golem.utils =
  title: (suffix) -> "#{golem.config.locale.TITLE} - #{suffix}"

  sendNotificationHTML5: (title, options, callback) ->
    options.timeout ?= 5
    _send = ->
      notif = new Notify title, options
      notif.show()
      callback() if callback

    _alert = ->
      alert "#{title} : #{options.body}"
      callback() if callback

    unless Notify.isSupported
      _alert()
    else
      if Notify.needsPermission
        Notify.requestPermission(_send, _alert)
      else
        _send()

  sendNotification: (config, callback) ->
    timeout = config.timeout
    config.timeout = (if (timeout or (timeout is false)) then timeout else 10)
    gnm = golem.notifications.model
    gnm.counter += 1
    gnm.items[gnm.counter] = config
    callback() if callback

  handlePouchError: (err, res, callbackSuccess, callbackAlways) ->
    if err
      golem.notifications.helpers.errorUnexpected body: err
    else
      callbackSuccess err, res
    callbackAlways() if callbackAlways
