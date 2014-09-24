# Activity form

This component is the form for adding or editing activities. It's materialized
by a class that inherits from `golem.component.Form`.

    g = golem
    notif = g.component.notification

    class Form extends g.component.Form


## Initialization

The constructor property puts in place the secondary menu and initializes the
model for the form, a blank one in the case of a new activity, or a filled one
when editing. A callback can be passed as first argument, which be called when
initialization is over with the main `view` function, returning the whole DOM.
The `id` is optional and refers to the document key in case of edition.

      constructor: (callback, id) ->
        mi = g.activity.model.data.menuItems
        g.menus.secondaryItems.replace [mi.list, mi.add]

        initNew = =>
          @activity = new g.Activity
          @add = true
          document.title = g.utils.title L 'ACTIVITIES_NEW'
          callback(@view()) if callback

        unless id
          initNew()
        else

In edit mode, we must check that the record is in database and gets it for
filling the form.

          g.db.get id, (err, res) =>
            warn = ->
              new notif.Warning(content: L('ERROR_RECORD_NOT_FOUND'))
                .send(displayCb: -> window.location.hash = '/activity')
            if err
              warn()
            else
              @activity = new g.Activity res
              unless @activity # TODO: check if real
                warn()
              else
                document.title = g.utils.title(
                  L 'EDITION_OF' + @activity.label.get())
                for act in ['show', 'edit', 'remove']
                  mi[act].url = "#{mi[act].baseUrl}/#{@activity._id.get()}"
                g.menus.secondaryItems.splice 2, 0, mi.show, mi.edit, mi.remove
                callback(@view()) if callback

## Methods

`submit` is the generic function inherited from `golem.component.Form` that
will send the form values.

      submit: (e) => Form.submit e, @activity

## Views

`form` is the private view function for building the whole view according to
the component activity.

      _form: ->
        labelField = do =>
          validation = Form.validate L('LASTNAME_VALIDATION_MSG'),
            (e) => @activity.label.set e.target.value
          div { class: 'eight wide field small input' }, [
            label { for: 'label' }, "#{L 'LABEL'} *"
            input
              type: 'text'
              name: 'label'
              placeholder: L 'LABEL'
              pattern: '.{2,}'
              maxlength: 100
              required: 'required'
              value: @activity.label.get()
              keyup: validation.fn
            validation.$elt
          ]
        codeField = div { class: 'four wide field small input' }, [
          label { for: 'code' }, L 'CODE'
          input
            type: 'text'
            name: 'code'
            placeholder: L 'CODE'
            maxlength: 30
            value: @activity.code.get()
            change: (e) => @activity.code.set e.target.value
        ]
        placesField = do =>
          validation = Form.validate L('PLACES_VALIDATION_MSG'),
            (e) => @activity.places.set parseInt(e.target.value)
          div { class: 'four wide field small input' }, [
            label { for: 'places' }, L 'PLACES'
            input
              id: 'places'
              name: 'places'
              placeholder: L 'PLACES'
              type: 'number'
              min: 0
              max: 1000
              step: 1
              value: @activity.places.get()
              keyup: validation.fn
            validation.$elt
          ]
        timeSlotField = div { class: 'ten wide field small input' }, [
          label { for: 'timeSlot', }, L 'TIMESLOT'
          input
            type: 'text'
            name: 'timeSlot'
            placeholder: L 'TIMESLOT'
            minlength: 2
            maxlength: 100
            value: @activity.timeSlot.get()
            change: (e) => @activity.timeSlot.set e.target.value
        ]
        monitorField = div { class: 'six wide field small input' }, [
          label { for: 'monitor' }, L 'MONITOR'
          input
            type: 'text'
            name: 'monitor'
            placeholder: L 'MONITOR'
            minlength: 2
            maxlength: 50
            value: @activity.monitor.get()
            change: (e) => @activity.monitor.set e.target.value
        ]
        noteField = div { class:'field' }, [
          label { for: 'note' }, L 'NOTE'
          textarea
            name: 'note'
            value: @activity.note.get()
            change: (e) => @activity.note.set e.target.value
          , @activity.note.get()
        ]
        form
          id: 'activity-form'
          class: 'ui small form'
          submit: @submit
          [
            div { class:'fields' }, [labelField, codeField, placesField]
            div { class:'fields' }, [timeSlotField, monitorField]
            noteField
            @sendInput()
            @cancelButton(null, -> window.location.hash = '#/activity')
          ]

`sidebar` is a private property defining the contextual content. Here are only
fixed position button for sending and cancelling the form. Usefull for finding
these buttons easily.

      _sidebar: -> menu { class: 'ui buttons fixed-right' }, [
        @sendInput('fluid')
        @cancelButton('fluid', -> window.location.hash = '#/activity')
      ]

`view` is the main view function, returning all the DOM elements needed for
this form.

      view: ->
        [
          section { class: 'twelve wide column' }, [
            golem.menus.secondary
            section { class: 'ui piled segment' }, [
              h2 { class: 'ui inverted center aligned purple header' }, do =>
                if @add
                  L('ACTIVITIES_NEW')
                else
                  "#{L('EDITION_OF')} #{@activity.label.get()}"
              @_form()
            ]
          ]
          section { class: 'four wide column' }, [@_sidebar()]
        ]


## Public API

    g.activity.component.Form = Form
