# Member form

    g = golem
    notif = g.component.notification

This component represents the Member form, for adding and for editing entities.
The class inherits from the shared `golem.component.Form`.


    class Form extends g.component.Form

## Initialization

The constructor property puts in place the secondary menu and initializes the
model for the form, a blank one in the case of a new member, or a filled one
when editing. A callback can be passed as first argument, which be called when
initialization is over with the main `$view` function, returning the whole DOM.
The `id` is optional and refers to the document key in case of edition.

      constructor: (@callback, @id) ->
        window.gForm = @
        mi = g.member.model.data.menuItems
        g.menus.secondaryItems.replace [mi.list, mi.add]
        if @id then @_initMember() else @_initNew()

## Methods

`initNew` is the method called when we are entering a new Member. It fixes a
boolean `@add` to true which will helps the views to know this state, creates
the `@member` to a virgin Member instance and updates the document's title. It
also call the `@callback`.

      _initNew: ->
        @add = true
        @member = new g.Member()
        document.title = g.utils.title L 'ACTIVITIES_NEW'
        @callback(@$view()) if @callback

`initMember` gets the document from the given identifier and returns a warning
if it's not found. It then affects the converted response to the `@member`
instance and change document title and secondary menu.

      _initMember: ->
        g.db.get @id, (err, res) =>
          warn = new notif.Warning content: L('ERROR_RECORD_NOT_FOUND'),
            window.location.hash = '#/member'
          if err
            warn.send()
          else
            @member = new g.Member res
            unless @member
              warn.send()
            else
              warn = undefined
              title = L('EDITION_OF') + @member.fullname.get()
              document.title = g.utils.title title
              for act in ['show', 'edit', 'remove']
                mi[act].url = "#{mi[act].baseUrl}/#{@member._id.get()}"
              g.menus.secondaryItems.splice 2, 0, mi.show, mi.edit, mi.remove
              callback(@$view()) if callback

`submit` is the generic function inherited from `golem.component.Form` that
will send the form values.

      submit: (e) => Form.submit e, @member

### Views


`$civility` contains all fields around the member's civility.

      _$civility: ->
        $number = div { class: 'four wide field' }, [
          label { for: 'number' }, L 'MEMBER_NUMBER'
          input
            type: 'text'
            name: 'number'
            placeholder: L 'MEMBER_NUMBER'
            maxlength: 20
            value: @member.number.get()
            change: (e) => @member.number.set e.target.value
        ]
        $lastname = do =>
          validation = Form.validate L('LASTNAME_VALIDATION_MSG'),
            (e) => @member.lastname.set e.target.value
          div { class: 'six wide field' }, [
            label { for: 'lastname' }, "#{L 'LASTNAME'} *"
            input
              type: 'text'
              name: 'lastname'
              placeholder: L 'LASTNAME'
              pattern: '.{2,}'
              maxlength: 100
              required: 'required'
              value: @member.lastname.get()
              keyup: validation.fn
            validation.$elt
          ]
        $firstname = do =>
          validation = Form.validate L('LASTNAME_VALIDATION_MSG'),
            (e) => @member.firstname.set e.target.value
          div { class: 'six wide field' }, [
            label { for: 'firstname' }, "#{L 'FIRSTNAME'} *"
            input
              type: 'text'
              name: 'firstname'
              placeholder: L 'FIRSTNAME'
              pattern: '.{2,}'
              maxlength: 100
              required: 'required'
              value: @member.firstname.get()
              keyup: validation.fn
            validation.$elt
          ]
        $gender =
          label: div { class: 'one wide field' }, L 'GENDER'
          male: div { class: 'two wide field' }, [
            div { class: 'ui radio checkbox' }, [
              input
                type: 'radio'
                id: 'gender-m',
                name: 'gender'
                value: 'm'
                checked: (@member.gender.get() is 'm')
                change: () => @member.gender.set 'm'
              label { for: 'gender-m' }, L 'GENDER_MALE'
            ]
          ]
          female: div { class: 'two wide field' }, [
            div { class: 'ui radio checkbox' }, [
              input
                type: 'radio'
                id: 'gender-f'
                name: 'gender'
                value: 'f'
                checked: (@member.gender.get() is 'f')
                change: () => @member.gender.set 'f'
              label { for: 'gender-f' }, L 'GENDER_FEMALE'
            ]
          ]
        $birthday = div { class: 'three wide field' }, [
          label { for: 'birthday' }, L 'BIRTHDAY'
          input
            type: 'text'
            name: 'birthday'
            placeholder: L 'BIRTHDAY_PLACEHOLDER'
            pattern: '\\d{2}/\\d{2}/\\d{4}'
            value: (if @member.birthday.get() then moment(@member.birthday.get()).format('L') else '')
            change: (e) =>
              v = e.target.value
              v = Form.dateFormat v
              if v
                @member.birthday.set v.toString()
                # If the person is minor, expand the fields
                isMinor = v.isAfter(moment().subtract(18, 'years'))
                if isMinor
                  @minorExpanded = true
                  if @add
                    @member.authorizations.set(activities: true, photos: true)
              else
                @member.birthday.set null
        ]
        $nationality = div { class: 'four wide field' }, [
          label { for: 'nationality' }, L 'NATIONALITY'
          input
            type: 'text'
            name: 'nationality'
            placeholder: L 'NATIONALITY'
            value: @member.nationality.get()
            change: (e) => @member.nationality.set e.target.value
        ]
        $profession = div { class: 'four wide field' }, [
          label { for: 'profession' }, L 'PROFESSION'
          input
            type: 'text'
            name: 'profession'
            placeholder: L 'PROFESSION'
            value: @member.profession.get()
            change: (e) => @member.profession.set e.target.value
        ]
        div [
          h3
            class: 'ui inverted center aligned purple header',
            L 'CIVILITY'
          div { class:'fields' }, [$number, $lastname, $firstname]
          div { class:'fields' }, [
            $gender.label, $gender.male, $gender.female,
            $birthday, $nationality, $profession
          ]
        ]

`$form` represents the whole form for adding or editing a member.

      _$form: ->
        form
          id: 'member-form'
          class: 'ui small form'
          submit: @submit,
          [@_$civility()]

`$sidebar`

      _$sidebar: -> div()

`$view` represents the whole DOM of the page, inclufing the form, the sidebar
and some DOM around.

      $view: ->
        title = do =>
          if @add
            L('MEMBERS_NEW')
          else
            "#{L('EDITION_OF')} #{@member.fullname.get()}"
        [
          section { class: 'twelve wide column' }, [
            golem.menus.$secondary
            section { class: 'ui piled segment' }, [
              h2 title
              @_$form()
            ]
          ]
          section { class: 'four wide column' }, [@_$sidebar()]
        ]

## Public API

    g.member.component.Form = Form
