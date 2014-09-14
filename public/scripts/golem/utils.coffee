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
