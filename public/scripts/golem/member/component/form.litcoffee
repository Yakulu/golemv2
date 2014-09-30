# Member form

    g = golem
    ns = g.module.member
    notif = g.component.notification
    gcform = g.component.form

This component represents the member form, for adding and for editing entities.
The functions employs the shared `golem.component.form`.

    mform =

## Initialization and launch

The launch functions employs the `golem.component.form.launch` common function
to put in place the secondary menu and to call the right function, according
the the presence of an `id`.

It then initializes the model for the form, a blank one in the case of a new
member, or a filled one when editing. A callback can be passed as first
argument, which be called when initialization is over with the main `form`
component, returning the whole DOM. The `id` is optional and refers to the
document key in case of edition.

      launch: (callback, id) -> gcform.launch ns, callback, id

## Methods

`initNew` is the method called when we are entering a new Member. It fixes a
property boolean `add` to true which will helps the views to know this state,
creates the `member` property to a virgin member object and updates the
document's title. It also call the `finish` function, which will handle the
`callback`.

      initNew: (callback) ->
        document.title = g.utils.title L 'MEMBERS_NEW'
        props = member: ns.model.member(), add: true
        gcform.init ns, props, callback
        mform.finish props

`initMember` gets the document from the given identifier and returns a warning
if it's not found. It then affects the converted response to the `member`
property instance and change document title and secondary menu.

      initEdit: (callback, id) ->
        mi = ns.model.data.menuItems
        props = {}
        g.db.get id, (err, res) ->
          warn = ->
            notif.send(
              notif.warning
                content: L('ERROR_RECORD_NOT_FOUND')
                displayCb: -> window.location.hash = '/activity')
          if err
            warn()
          else
            props.member = ns.model.member res
            unless props.member
              warn()
            else
              title = L('EDITION_OF') + props.member.fullname.get()
              document.title = g.utils.title title
              for act in ['show', 'edit', 'remove']
                mi[act].url = "#{mi[act].baseUrl}/#{props.member._id.get()}"
              g.menus.secondaryItems.splice 2, 0, mi.show, mi.edit, mi.remove
              gcform.init ns, props, callback
              mform.finish props

## Methods

`submit` is the generic function that uses the `golem.component.form` that
will send the form values.

      submit: (props, e) -> gcform.submit e, props.member

### Form Views

      views:

#### Fields

Fields are built one per one, according to the needs. They're all composable
and take the values of the HTML fields, on change or on input.

        fields:

`number` is a manual identifier used by the MJC, an optional string for us.

          number: (props) ->
            props.$dom = div { class: 'four wide field' }, [
              label { for: 'number' }, L 'MEMBER_NUMBER'
              input
                type: 'text'
                name: 'number'
                placeholder: L 'MEMBER_NUMBER'
                maxlength: 20
                value: props.member.number.get()
                change: (e) -> props.member.number.set e.target.value
            ]
            props

`lastname` is a required string field, using realtime validation.

          lastname: (props) ->
            validation = gcform.validate L('LASTNAME_VALIDATION_MSG'),
              (e) -> props.member.lastname.set e.target.value
            props.$dom = div { class: 'six wide field' }, [
              label { for: 'lastname' }, "#{L 'LASTNAME'} *"
              input
                type: 'text'
                name: 'lastname'
                placeholder: L 'LASTNAME'
                pattern: '.{2,}'
                maxlength: 100
                required: 'required'
                value: props.member.lastname.get()
                keyup: validation.fn
              validation.$elt
            ]
            props

`firstname` required string field.

          firstname: (props) ->
            validation = gcform.validate L('LASTNAME_VALIDATION_MSG'),
              (e) -> props.member.firstname.set e.target.value
            props.$dom = div { class: 'six wide field' }, [
              label { for: 'firstname' }, "#{L 'FIRSTNAME'} *"
              input
                type: 'text'
                name: 'firstname'
                placeholder: L 'FIRSTNAME'
                pattern: '.{2,}'
                maxlength: 100
                required: 'required'
                value: props.member.firstname.get()
                keyup: validation.fn
              validation.$elt
            ]
            props

`gender` optional radio field, with the label, male and female.

          gender:
            label: (props) ->
              props.$dom = div { class: 'one wide field' }, L 'GENDER'
              props
            male: (props) ->
              props.$dom = div { class: 'two wide field' }, [
                div { class: 'ui radio checkbox' }, [
                  input
                    type: 'radio'
                    id: 'gender-m',
                    name: 'gender'
                    value: 'm'
                    checked: (props.member.gender.get() is 'm')
                    change: () -> props.member.gender.set 'm'
                  label { for: 'gender-m' }, L 'GENDER_MALE'
                ]
              ]
              props
            female: (props) ->
              props.$dom = div { class: 'two wide field' }, [
                div { class: 'ui radio checkbox' }, [
                  input
                    type: 'radio'
                    id: 'gender-f'
                    name: 'gender'
                    value: 'f'
                    checked: (props.member.gender.get() is 'f')
                    change: () -> props.member.gender.set 'f'
                  label { for: 'gender-f' }, L 'GENDER_FEMALE'
                ]
              ]
              props

`birthday` optional date field, with french formatting.

          birthday: (props) ->
            props.$dom = div { class: 'three wide field' }, [
              label { for: 'birthday' }, L 'BIRTHDAY'
              input
                type: 'text'
                name: 'birthday'
                placeholder: L 'BIRTHDAY_PLACEHOLDER'
                pattern: '\\d{2}/\\d{2}/\\d{4}'
                value: (if props.member.birthday.get() then moment(props.member.birthday.get()).format('L') else '')
                change: (e) =>
                  v = e.target.value
                  v = gcform.dateFormat v
                  if v
                    props.member.birthday.set v.toString()
                    # If the person is minor, expand the fields
                    isMinor = v.isAfter(moment().subtract(18, 'years'))
                    if isMinor
                      props.minorExpanded = true
                      if props.add
                        props.member.authorizations.set(activities: true, photos: true)
                  else
                    props.member.birthday.set null
            ]
            props

`nationality` optional string

          nationality: (props) ->
            props.$dom = div { class: 'four wide field' }, [
              label { for: 'nationality' }, L 'NATIONALITY'
              input
                type: 'text'
                name: 'nationality'
                placeholder: L 'NATIONALITY'
                value: props.member.nationality.get()
                change: (e) -> props.member.nationality.set e.target.value
            ]
            props

`profession` optional string

          profession: (props) ->
            props.$dom = div { class: 'four wide field' }, [
              label { for: 'profession' }, L 'PROFESSION'
              input
                type: 'text'
                name: 'profession'
                placeholder: L 'PROFESSION'
                value: props.member.profession.get()
                change: (e) -> props.member.profession.set e.target.value
            ]
            props

#### Composable views

`civility` contains all fields around the member's civility.

        civility: (props) ->
          vf = mform.views.fields
          props.$dom = div [
            h3
              class: 'ui inverted center aligned purple header',
              L 'CIVILITY'
            div { class:'fields' }, [
              vf.number(props).$dom
              vf.lastname(props).$dom
              vf.firstname(props).$dom
            ]
            div { class:'fields' }, [
              vf.gender.label(props).$dom
              vf.gender.male(props).$dom
              vf.gender.female(props).$dom
              vf.birthday(props).$dom
              vf.nationality(props).$dom
              vf.profession(props).$dom
            ]
          ]
          props

`form` represents the whole form for adding or editing a member.

        form: (props) ->
          props.$dom = form
            id: 'member-form'
            class: 'ui small form'
            submit: mform.submit,
            [props.$dom]
          props

`sidebar`

        sidebar: (props) -> props.$dom = div(); return props

`layout` represents the whole DOM of the page, inclufing the form, the sidebar
and some DOM around.

        layout: (props) ->
          title = do ->
            if props.add
              L('MEMBERS_NEW')
            else
              "#{L('EDITION_OF')} #{props.member.fullname.get()}"
          props.$dom = [
            section { class: 'twelve wide column' }, [
              golem.menus.secondary
              section { class: 'ui piled segment' }, [
                h2 title
                props.$dom
              ]
            ]
            section { class: 'four wide column' }, [
              mform.views.sidebar(props).$dom
            ]
          ]
          props

## Components

      components:

`form` is the unique component of this page, composing all views and passing to
them the `props` objects, updated to add mandatory functions in our situation.

        form: (props) ->
          v = mform.views
          _.compose(v.layout, v.form, v.civility)(props)

## Public API

    ns.component.form = mform
