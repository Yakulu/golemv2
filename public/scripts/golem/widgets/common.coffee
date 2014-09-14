l = golem.config.locale
golem.widgets.common =
  modal:
    controller: (config) ->
      # Defaults
      @active = config.active or false
      @toggle = => @active = not @active
      # Init
      {@title, @content, @acceptFn} = config
      @cancelFn = config.cancelFn or @toggle
      return

    view: (ctrl) ->
      cls = if ctrl.active then ' active visible' else ''
      m 'div', { class: "ui dimmer page#{cls}" }, [
        m 'div', { class: "ui basic modal#{cls}" }, [
          m 'i', { class: 'close icon', onclick: ctrl.cancelFn }
          m 'div.header', ctrl.title
          m 'div.content', m.trust ctrl.content
          m 'div.actions', [
            m 'button',
              class: 'ui negative button'
              type: 'button'
              onclick: ctrl.cancelFn,
              l.CANCEL
            m 'button',
              class: 'ui positive button'
              type: 'button'
              onclick: ctrl.acceptFn,
              l.OK
          ]
        ]
      ]
  notifications:
    send: (options, callback) ->
      options.timeout ?= 10
      gnm = golem.widgets.common.notifications.model
      gnm.counter += 1
      gnm.items[gnm.counter] = options
      callback() if callback?

    success: (options, callback) ->
      options.title ?= l.SUCCESS
      options.cls = 'success'
      options.icon = 'checkmark'
      golem.widgets.common.notifications.send options, callback

    info: (options, callback) ->
      options.title ?= l.INFO
      options.cls = options.icon = 'info'
      golem.widgets.common.notifications.send options, callback

    warning: (options, callback) ->
      options.title = l.WARNING
      options.cls = options.icon = 'warning'
      options.timeout = 15
      golem.widgets.common.notifications.send options, callback

    error: (options, callback) ->
      options.title = l.ERROR
      options.cls = 'error'
      options.icon = 'attention'
      options.timeout = false
      golem.widgets.common.notifications.send options, callback

    errorUnexpected: (options, callback) ->
      options.body = "<em>#{options.body}</em><br>#{l.ERROR_UNEXPECTED}"
      golem.widgets.common.notifications.error options, callback

    model:
      items: {} # list of items by id -> item
      counter: 0 # id autoincrement

    controller: ->
      gnm = golem.widgets.common.notifications.model
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
      gnm = golem.widgets.common.notifications.model
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
