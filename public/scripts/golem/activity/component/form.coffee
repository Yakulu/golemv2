module = golem.module.activity
wform = golem.widgets.form
module.component.form =
  controller: ->
    l = golem.config.locale
    mi = module.data.menuItems
    golem.menus.secondary.items = [mi.list, mi.add]
    newActivity = =>
      @activity = module.model.create {}
      @add = true
      document.title = golem.utils.title l.ACTIVITIES_NEW

    key = m.route.param 'activityId'
    unless key
      newActivity()
    else
      m.startComputation()
      golem.model.db.get key, (err, res) =>
        if err
          golem.notifications.helpers.warning body: l.ERROR_RECORD_NOT_FOUND
          m.route '/activity/list'
        else
          @activity = res
          unless @activity
            newMember()
          else
            document.title = golem.utils.title l.CONTACTS_EDIT + @activity.label
            for action in ['show', 'edit', 'remove']
              mi[action].url = "#{mi[action].baseUrl}/#{@activity._id}"
            golem.menus.secondary.items = [
              mi.list
              mi.add
              mi.show
              mi.edit
              mi.remove
            ]
        m.endComputation()

    @submit = golem.component.form.submit.bind this, 'activity'
    return

  view: (ctrl) ->
    l = golem.config.locale
    a = ctrl.activity
    form = golem.widgets.form
    h2 = (if ctrl.add then l.ACTIVITIES_NEW else "#{l.CONTACTS_EDIT}  #{a.label}")
    mainContent = m 'section', { class: 'ui piled segment' }, [
      m 'h2', h2
      m 'form',
        id: 'activity-form'
        class: 'ui small form'
        onsubmit: ctrl.submit,
        [
          m 'div.fields', [
            form.textHelper
              cls: 'eight wide field small input'
              name: 'label'
              label: l.LABEL
              minlength: 2
              maxlength: 100
              required: true
              value: a.label
              validationMsg: l.LASTNAME_VALIDATION_MSG
              validationCallback: (e) -> a.label = e.target.value
            form.textHelper
              cls: 'four wide field small input'
              name: 'code'
              label: l.CODE
              minlength: 2
              maxlength: 30
              value: a.code
              onchange: m.withAttr 'value', (v) -> a.code = v
            m 'div', { class: 'four wide field small input' }, [
              m 'label', { for: 'places' }, l.PLACES
              m 'input',
                id: 'places'
                name: 'places'
                type: 'number'
                min: 0
                max: 10000
                step: 1
                value: a.places
                oninput: m.withAttr 'value', (v) ->
                  # Ensure this is a number and it's not under 0
                  v = parseInt v
                  if isNaN v
                    a.places = null
                  else
                    a.places = (if (v < 0) then null else v)
            ]
          ]
          m 'div.fields', [
            form.textHelper
              cls: 'ten wide field small input'
              name: 'timeSlot'
              label: l.TIMESLOT
              minlength: 2
              maxlength: 100
              value: a.timeSlot
              onchange: m.withAttr 'value', (v) -> a.timeSlot = v
            form.textHelper
              cls: 'six wide field small input'
              name: 'monitor'
              label: l.MONITOR
              minlength: 2
              maxlength: 50
              value: a.monitor
              onchange: m.withAttr 'value', (v) -> a.monitor = v
          ]
        m 'div.field', [
          m 'label', { for: 'note' }, l.NOTE
          m 'textarea',
            name: 'note'
            value: a.note
            onchange: m.withAttr 'value', (v) -> a.note = v
          , a.note
        ]
        m 'input',
          id: 'activity-submit'
          class: 'ui teal submit button'
          type: 'submit'
          form: 'activity-form'
          value: (if ctrl.add then l.SAVE else l.UPDATE)
        m 'button',
          name: 'cancel'
          class: 'ui button'
          type: 'button'
          onclick: -> window.location.hash = '#/activity/list',
          l.CANCEL
      ]
    ]
    contextMenuContent = m 'nav', [
      m 'menu', { class: 'ui buttons fixed-right' }, [
        m 'input',
          class: 'ui fluid teal submit button'
          type: 'submit'
          value: (if ctrl.add then l.SAVE else l.UPDATE)
          # FIXME : here's a hack, to fix properly
          onclick: -> document.getElementById('activity-submit').click()
        m 'div',
          role: 'button'
          class: 'ui fluid button'
          onclick: (e) -> window.location = '#/activity/list',
          l.CANCEL
      ]
    ]
    return [
      m 'section', { class: 'twelve wide column' }, [
        new golem.menus.secondary.view()
        mainContent
      ]
      m 'section', { class: 'four wide column' }, contextMenuContent
    ]
