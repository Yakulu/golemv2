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
