l = golem.config.locale
widgets = golem.widgets.common
golem.component.remove = (props) ->
  unless props.acceptFn
    props.acceptFn = (item) ->
      golem.model.db.remove item, (err, res) ->
        if err
          golem.widgets.common.notifications.errorUnexpected body: err
        else
          golem.widgets.common.notifications.success body: l.SUCCESS_DELETE
        m.route props.route
  return {
    controller: ->
      key = m.route.param props.key
      m.startComputation()
      golem.model.db.get key, (err, res) =>
        if err
          golem.widgets.common.notifications.error body: l.ERROR_RECORD_NOT_FOUND
        else
          @item = res
          document.title = golem.utils.title(l.CONTACTS_REMOVE + props.nameFn(@item))
          @removeModalCtrl = new widgets.modal.controller
            active: true
            title: l.SURE
            content: l[props.confirm]
            acceptFn: props.acceptFn.bind this, @item
            cancelFn: =>
              @removeModalCtrl.toggle()
              m.route props.route
        m.endComputation()
      return

    view: (ctrl) ->
      m 'section',
        class: 'twelve wide column',
        new widgets.modal.view ctrl.removeModalCtrl
  }
