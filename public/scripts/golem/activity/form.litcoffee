# Activity form

This component is the form for adding or editing activities. It's materialized
by an objecy using `golem.common.form`.

    g = golem
    ns = g.module.activity
    notif = g.common.notification
    gcform = g.common.form

    aform = {}

## Initialization and launch

The launch initializes the model for the form, a blank one in the case of a new
activity, or a filled one when editing. A callback can be passed as first
argument, which be called when initialization is over with the main
`views.form` function, returning the whole DOM.  The `id` is optional and
refers to the document key in case of edition. Is also calls the common `init`
form function, setting up a `finish` function when needed.

    aform.launch = (callback, id) -> gcform.launch ns, callback, id

    aform.initNew = (callback) ->
      document.title = g.utils.title L 'ACTIVITIES_NEW'
      props = activity: ns.model.activity(), add: true
      gcform.init ns, props, callback
      aform.finish props

In edit mode, we must check that the record is in database and gets it for
filling the form.

    aform.initEdit = (callback, id) ->
      mi = ns.model.data.menuItems
      props = {}
      g.db.get id, (err, res) ->
        warn = ->
          notif.send(
            notif.warning
              content: L('ERROR_RECORD_NOT_FOUND'),
              displayCb: -> window.location.hash = '/activity')
        if err
          warn()
        else
          props.activity = ns.model.activity res
          unless props.activity # TODO: check if real
            warn()
          else
            document.title = g.utils.title(
              L 'EDITION_OF' + props.activity.label.get())
            for act in ['show', 'edit', 'remove']
              mi[act].url = "#{mi[act].baseUrl}/#{props.activity._id.get()}"
            g.menus.secondaryItems.splice 2, 0, mi.show, mi.edit, mi.remove
            gcform.init ns, props, callback
            aform.finish props

## Methods

`submit` is the generic function using `common.form.submit` that will send
the form values.

    aform.submit = (props, e) -> gcform.submit e, props.activity

## Form Views

    aform.views = {}

Fields are built one per one, according to the needs. They're all composable
and take the values of the HTML fields, on change or on input.

    aform.views.fields = {}

`label` is mandatory, with a minimum of 2 caracters. It uses the reactive
validation created here for GOLEM.

    aform.views.fields.label = (props) ->
      validation = gcform.validate L('LASTNAME_VALIDATION_MSG'),
        (e) -> props.activity.label.set e.target.value
      props.$dom = div { class: 'eight wide field small input' }, [
        label { for: 'label' }, "* #{L 'LABEL'}"
        input
          type: 'text'
          name: 'label'
          placeholder: L 'LABEL'
          pattern: '.{2,}'
          maxlength: 100
          required: 'required'
          value: props.activity.label.get()
          keyup: validation.fn
        validation.$elt
      ]
      props

`code` is an optional string.

    aform.views.fields.code = (props) ->
      props.$dom = div { class: 'four wide field small input' }, [
        label { for: 'code' }, L 'CODE'
        input
          type: 'text'
          name: 'code'
          placeholder: L 'CODE'
          maxlength: 30
          value: props.activity.code.get()
          change: (e) -> props.activity.code.set e.target.value
      ]
      props

`places` is optional but must be an signed integer.

    aform.views.fields.places = (props) ->
      validation = gcform.validate L('PLACES_VALIDATION_MSG'),
        (e) -> props.activity.places.set parseInt e.target.value
      props.$dom = div { class: 'four wide field small input' }, [
        label { for: 'places' }, L 'PLACES'
        input
          id: 'places'
          name: 'places'
          placeholder: L 'PLACES'
          type: 'number'
          min: 0
          max: 1000
          step: 1
          value: props.activity.places.get()
          keyup: validation.fn
        validation.$elt
      ]
      props

`timeSlot` is an optional string.

    aform.views.fields.timeSlot = (props) ->
      props.$dom = div { class: 'ten wide field small input' }, [
        label { for: 'timeSlot', }, L 'TIMESLOT'
        input
          type: 'text'
          name: 'timeSlot'
          placeholder: L 'TIMESLOT'
          minlength: 2
          maxlength: 100
          value: props.activity.timeSlot.get()
          change: (e) -> props.activity.timeSlot.set e.target.value
      ]
      props

`monitor` optional string.

    aform.views.fields.monitor = (props) ->
      props.$dom = div { class: 'six wide field small input' }, [
        label { for: 'monitor' }, L 'MONITOR'
        input
          type: 'text'
          name: 'monitor'
          placeholder: L 'MONITOR'
          minlength: 2
          maxlength: 50
          value: props.activity.monitor.get()
          change: (e) -> props.activity.monitor.set e.target.value
      ]
      props

`note` optional long text description.

    aform.views.fields.note = (props) ->
      props.$dom = div { class:'field' }, [
        label { for: 'note' }, L 'NOTE'
        textarea
          name: 'note'
          value: props.activity.note.get()
          change: (e) -> props.activity.note.set e.target.value
        , props.activity.note.get()
        ]
      props

`form` is the private view function for building the main view according to
the component activity.

    aform.views.form = (props) ->
      vf = aform.views.fields
      props.$dom = form
        id: 'activity-form'
        class: 'ui small form'
        submit: _.partial aform.submit, props
        [
          div { class:'fields' }, [
            vf.label(props).$dom
            vf.code(props).$dom
            vf.places(props).$dom
          ]
          div { class:'fields' }, [
            vf.timeSlot(props).$dom
            vf.monitor(props).$dom
          ]
          vf.note(props).$dom
          gcform.views.sendInput()
          gcform.views.cancelButton(null, ->
            window.location.hash = '#/activity')
        ]
      props

`sidebar` is a private property defining the contextual content. Here are only
fixed position button for sending and cancelling the form. Usefull for finding
these buttons easily.

    aform.views.sidebar = (props) ->
      props.$dom = menu { class: 'ui buttons fixed-right' }, [
        gcform.views.sendInput('fluid')
        gcform.views.cancelButton('fluid', ->
          window.location.hash = '#/activity')
      ]
      props

`layout` is the main view function, returning all the DOM elements needed for
this form.

    aform.views.layout = (props) ->
      props.$dom = [
        section { class: 'twelve wide column' }, [
          golem.menus.secondary
          section { class: 'ui piled segment' }, [
            h2 { class: 'ui inverted center aligned purple header' }, do ->
              if props.add
                L('ACTIVITIES_NEW')
              else
                "#{L('EDITION_OF')} #{props.activity.label.get()}"
            props.$dom
          ]
        ]
        section { class: 'four wide column' }, [
          aform.views.sidebar(props).$dom
        ]
      ]
      props

## Components

    aform.components = {}

`form` is the unique component of this page, composing all views and passing to
them the `props` objects, updated to add mandatory functions in our situation.

    aform.components.form = (props) ->
      v = aform.views
      _.compose(v.layout, v.form)(props)

## Public API

    ns.form = aform
