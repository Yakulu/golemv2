l = golem.config.locale
golem.notifications =
  helpers:
    base: (@options, callback) ->
      golem.utils.sendNotification @options, callback

    success: (options, callback) ->
      options.title ?= l.SUCCESS
      options.cls = 'success'
      options.icon = 'checkmark'
      golem.notifications.helpers.base options, callback

    info: (options, callback) ->
      options.title ?= l.INFO
      options.cls = options.icon = 'info'
      golem.notifications.helpers.base options, callback

    warning: (options, callback) ->
      options.title = l.WARNING
      options.cls = options.icon = 'warning'
      options.timeout = 15
      golem.notifications.helpers.base options, callback

    error: (options, callback) ->
      options.title = l.ERROR
      options.cls = 'error'
      options.icon = 'attention'
      options.timeout = false
      golem.notifications.helpers.base options, callback

    errorUnexpected: (options, callback) ->
      options.body = "<em>#{options.body}</em><br>#{l.ERROR_UNEXPECTED}"
      golem.notifications.helpers.error options, callback

  model:
    items: {} # list of items by id -> item
    counter: 0 # id autoincrement

  controller: ->
    gnm = golem.notifications.model
    @toClose = {}
    @close = (id, from) =>
      # with from false, no clear because notimeout
      window.clearTimeout(@toClose[id]) if from and from isnt 'timeout'
      delete @toClose[id]
      delete gnm.items[id]

    @delayClose = (id, timeout) =>
      if timeout and not @toClose[id]
        @toClose[id] = window.setTimeout =>
          @close id, 'timeout'
          m.redraw()
        , timeout * 1000
    return

  view: (ctrl) ->
    gnm = golem.notifications.model
    keys = Object.keys(gnm.items).sort()
    m 'div', keys.map (id) ->
      n = gnm.items[id]
      ctrl.delayClose id, n.timeout
      closeFn = ctrl.close.bind ctrl, id, n.timeout
      notifClass = ['ui', 'floating', 'message', 'notification']
      notifClass.push n.cls if n.cls
      notifClass.push 'icon' if n.icon
      m 'div',
        class: notifClass.join ' '
        onclick: if n.click then n.click else closeFn
      , [
        if n.icon then m 'i', { class: n.icon + ' icon' } else ''
        m 'i',
          class: 'close icon'
          onclick: closeFn
        m 'div.content', [
          m 'div.header', n.title
          m 'p', m.trust n.body
        ]
      ]
