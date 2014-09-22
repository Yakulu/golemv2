# Activity form

This component is the form for adding or editing activities.

    g = golem
    notif = g.component.notification

    class Form extends g.component.Form

The constructor property puts in place the secondary menu and initializes the
model for the form, a blank one in the case of a new activity, or a filled one
when editing. A callback can be passed as first argument, which be called when
initialization is over with the main `$view` function, returning the whole DOM.
The `id` is optional and refers to the document key in case of edition.

      constructor: (callback, id) ->
        window.gForm = @
        mi = g.activity.model.data.menuItems
        g.menus.secondaryItems.replace [mi.list, mi.add]

        initNew = =>
          @activity = new g.Activity
          @add = true
          document.title = g.utils.title L 'ACTIVITIES_NEW'
          callback(@$view()) if callback

        unless id
          initNew()
        else

In edit mode, we must check that the record is in database and gets it for
filling the form.

          g.db.get id, (err, res) =>
            if err
              new notif.Warning body: l.ERROR_RECORD_NOT_FOUND,
                window.location.hash = '#/activity/list'
              .send()
            else
              @activity = new g.Activity res
              unless @activity # TODO: check if real
                initNew()
              else
                document.title = g.utils.title(
                  L 'EDITION_OF' + @activity.label.get())
                for act in ['show', 'edit', 'remove']
                  mi[act].url = "#{mi[act].baseUrl}/#{@activity._id.get()}"
                g.menus.secondaryItems.splice 2, 0, mi.show, mi.edit, mi.remove
                callback(@$view()) if callback

`submit` is the generic function inherited from `golem.component.Form` that
will send the form values.

      submit: (e) => golem.component.Form.submit e, @activity

`$cancelButton` and `$sendInput` are the two buttons for sending and cancelling
the form. They will be used at the bottom of the form and on the contextual
menu too.

      _$cancelButton: (cls) ->
        button
          name: 'cancel'
          class: "ui button #{cls}"
          type: 'button'
          click: -> window.location.hash = '#/activity/list',
          L 'CANCEL'

      _$sendInput: (cls) ->
        input
          id: 'activity-submit'
          class: "ui teal submit button #{cls}"
          type: 'submit'
          form: 'activity-form'
          value: (if @add then L 'SAVE' else L 'UPDATE')

`$form` is the private view function for building the whole view according to
the component activity.

      _$form: ->
        $labelField = do =>
          validation = g.component.Form.validate L('LASTNAME_VALIDATION_MSG'),
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
        $codeField = div { class: 'four wide field small input' }, [
          label { for: 'code' }, L 'CODE'
          input
            type: 'text'
            name: 'code'
            placeholder: L 'CODE'
            minlength: 2
            maxlength: 30
            value: @activity.code.get()
            change: (e) => @activity.code.set e.target.value
        ]
        # TODO : use pattern validation and custom fn for it
        $placesField = do =>
          validation = g.component.Form.validate L('PLACES_VALIDATION_MSG'),
            (e) => @activity.places.set e.target.value
          div { class: 'four wide field small input' }, [
            label { for: 'places' }, L 'PLACES'
            input
              id: 'places'
              name: 'places'
              placeholder: L 'PLACES'
              type: 'number'
              min: 0
              max: 10000
              step: 1
              value: @activity.places.get()
              keyup: validation.fn
            validation.$elt
          ]
        $timeSlotField = div { class: 'ten wide field small input' }, [
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
        $monitorField = div { class: 'six wide field small input' }, [
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
        $noteField = div { class:'field' }, [
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
            div { class:'fields' }, [$labelField, $codeField, $placesField]
            div { class:'fields' }, [$timeSlotField, $monitorField]
            $noteField
            @_$sendInput()
            @_$cancelButton()
          ]

`$context` is a private property defining the contextuel content. Here are only
fixed position button for sending and cancelling the form. Usefull for finding
these buttons easily.

      _$context: -> menu { class: 'ui buttons fixed-right' }, [
        @_$sendInput('fluid'), @_$cancelButton('fluid')
      ]

`$view` is the main view function, returning all the DOM elements needed for
this form.

      $view: ->
        [
          section { class: 'twelve wide column' }, [
            golem.menus.$secondary
            section { class: 'ui piled segment' }, [
              h2 { class: 'ui inverted center aligned purple header' }, do =>
                if @add
                  L('ACTIVITIES_NEW')
                else
                  "#{L('EDITION_OF')} #{@activity.label.get()}"
              @_$form()
            ]
          ]
          section { class: 'four wide column' }, [@_$context()]
        ]


## Public API

    g.activity.component.Form = Form
