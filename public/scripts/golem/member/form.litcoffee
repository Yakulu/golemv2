# Member form

    g = golem
    ns = g.module.member
    notif = g.common.notification
    gcform = g.common.form

This component represents the member form, for adding and for editing entities.
The functions employs the shared `golem.common.form`.

    mform = {}

## Initialization and launch

The launch functions employs the `golem.common.form.launch` common function
to put in place the secondary menu and to call the right function, according
the the presence of an `id`.

It then initializes the model for the form, a blank one in the case of a new
member, or a filled one when editing. A callback can be passed as first
argument, which be called when initialization is over with the main `form`
component, returning the whole DOM. The `id` is optional and refers to the
document key in case of edition.

    mform.launch = (callback, id) -> gcform.launch ns, callback, id

## Methods

`initNew` is the method called when we are entering a new Member. It fixes a
property boolean `add` to true which will helps the views to know this state,
creates the `member` property to a virgin member object and updates the
document's title. It also call the `finish` function, which will handle the
`callback`.

    mform.initNew = (callback) ->
      document.title = g.utils.title L 'MEMBERS_NEW'
      props = member: ns.model.member(), add: true, minorExpanded: rx.cell false
      gcform.init ns, props, callback
      mform.finish props

`initMember` gets the document from the given identifier and returns a warning
if it's not found. It then affects the converted response to the `member`
property instance and change document title and secondary menu.

    mform.initEdit = (callback, id) ->
      mi = ns.model.data.menuItems
      props = minorExpanded: rx.cell false
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

`submit` is the generic function that uses the `golem.common.form` that
will send the form values.

    mform.submit = (props, e) -> gcform.submit e, props.member

### Form Views

    mform.views = {}

#### Fields

Fields are built one per one, according to the needs. They're all composable
and take the values of the HTML fields, on change or on input.

    mform.views.fields = {}

`number` is a manual identifier used by the MJC, an optional string for us.

    mform.views.fields.number = (props) ->
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

    mform.views.fields.lastname = (props) ->
      validation = gcform.validate L('LASTNAME_VALIDATION_MSG'),
        (e) -> props.member.lastname.set e.target.value
      props.$dom = div { class: 'six wide field' }, [
        label { for: 'lastname' }, "* #{L 'LASTNAME'}"
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

    mform.views.fields.firstname = (props) ->
      validation = gcform.validate L('LASTNAME_VALIDATION_MSG'),
        (e) -> props.member.firstname.set e.target.value
      props.$dom = div { class: 'six wide field' }, [
        label { for: 'firstname' }, "* #{L 'FIRSTNAME'}"
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

    mform.views.fields.gender =
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

    mform.views.fields.birthday = (props) ->
      props.$dom = div { class: 'three wide field' }, [
        label { for: 'birthday' }, L 'BIRTHDAY'
        input
          type: 'text'
          name: 'birthday'
          placeholder: L 'BIRTHDAY_PLACEHOLDER'
          pattern: '\\d{2}/\\d{2}/\\d{4}'
          value: bind ->
            if props.member.birthday.get()
              moment(props.member.birthday.get()).format('L')
            else
              ''
          change: (e) ->
            v = e.target.value
            v = gcform.dateFormat v
            if v
              props.member.birthday.set v.toString()
              # If the person is minor, expand the fields
              # TODO: export from here, it's a simple formula !!
              isMinor = v.isAfter(moment().subtract(18, 'years'))
              if isMinor
                props.minorExpanded = true
                if props.add
                  props.member.authorizations.set activities: true, photos: true
            else
              props.member.birthday.set null
      ]
      props

`nationality` optional string

    mform.views.fields.nationality = (props) ->
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

    mform.views.fields.profession = (props) ->
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

`address` string field

    mform.views.fields.address = (props) ->
      props.$dom = div { class: 'field' }, [
        label { for: 'address' }, "#{L 'ADDRESS'}"
        input
          type: 'text'
          name: 'address'
          placeholder: L 'ADDRESS'
          maxlength: 150
          value: props.member.address.get()
          change: (e) -> props.member.address.set e.target.value
      ]
      props

`postalCode` field, must be a 5 numeric char string

    mform.views.fields.postalCode = (props) ->
      validation = gcform.validate L('POSTAL_CODE_VALIDATION_MSG'),
        (e) -> props.member.postalCode.set e.target.value
      props.$dom = div { class: 'field' }, [
        label { for: 'postalCode' }, "#{L 'POSTAL_CODE'}"
        input
          type: 'text'
          name: 'postalCode'
          placeholder: L 'POSTAL_CODE'
          maxlength: 5
          pattern: '^\\d{5}$'
          value: props.member.postalCode.get()
          keyup: validation.fn
        validation.$elt
      ]
      props

`city` string field

    mform.views.fields.city = (props) ->
      props.$dom = div { class: 'field' }, [
        label { for: 'city' }, "#{L 'CITY'}"
        input
          type: 'text'
          name: 'city'
          placeholder: L 'CITY'
          maxlength: 100
          value: props.member.city.get()
          change: (e) -> props.member.city.set e.target.value
      ]
      props

`communicationModes` contains two checkbox fields for giving the authorization
to be contacted by email or telephone.

    mform.views.fields.communicationModes = (props) ->
      cmodes = props.member.communicationModes.get()
      props.$dom = [
        div { class: 'field' }, L 'COMMUNICATION_MODES'
        div { class: 'inline field' }, [
          input
            type: 'checkbox'
            id: 'cmodes-mail'
            name: 'cmodes-mail'
            checked: cmodes.mail
            change: (e) ->
              cmodes.mail = e.target.checked
              props.member.communicationModes.set cmodes
          label { for: 'cmodes-mail' }, L 'MAIL'
        ]
        div { class: 'inline field' }, [
          input
            type: 'checkbox'
            id: 'cmodes-tel'
            name: 'cmodes-tel'
            checked: cmodes.tel
            change: (e) ->
              cmodes.tel = e.target.checked
              props.member.communicationModes.set cmodes
          label { for: 'cmodes-tel' }, L 'TEL'
        ]
      ]
      props

`guardianLastname` is required only if the member is minor and uses realtime
validation.

    mform.views.fields.guardianLastname = (props) ->
      validation = gcform.validate L('LASTNAME_VALIDATION_MSG'),
        (e) -> props.member.guardianLastname.set e.target.value
      props.$dom = div { class: 'three wide field' }, [
        label { for: 'guardian-lastname' }, "* #{L 'LASTNAME'}"
        input
          type: 'text'
          name: 'guardian-lastname'
          placeholder: L 'LASTNAME'
          pattern: '.{2,}'
          maxlength: 100
          required: 'required'
          value: props.member.guardianLastname.get()
          keyup: validation.fn
        validation.$elt
      ]
      props

`guardianFirstname` is required only if the member is minor and uses realtime

    mform.views.fields.guardianFirstname = (props) ->
      validation = gcform.validate L('LASTNAME_VALIDATION_MSG'),
        (e) -> props.member.guardianFirstname.set e.target.value
      props.$dom = div { class: 'three wide field' }, [
        label { for: 'guardian-firstname' }, "* #{L 'FIRSTNAME'}"
        input
          type: 'text'
          name: 'guardian-firstname'
          placeholder: L 'FIRSTNAME'
          pattern: '.{2,}'
          maxlength: 100
          required: 'required'
          value: props.member.guardianFirstname.get()
          keyup: validation.fn
        validation.$elt
      ]
      props

`authorizations` contains two checkbox fields for giving the permission to the
minor to participate to activities and being taking in photography.

    mform.views.fields.authorizations = (props) ->
      auth = props.member.authorizations.get()
      props.$dom = [
        div { class: 'two wide field' }, L 'AUTHORIZATIONS'
        div { class: 'three wide inline field' }, [
          input
            type: 'checkbox'
            id: 'authorizations-activities'
            name: 'authorizations-activities'
            checked: auth.activities
            change: (e) ->
              auth.activities = e.target.checked
              props.member.authorizations.set auth
          label { for: 'authorizations-activities' }
          , L 'ACTIVITIES_PARTICIPATION'
        ]
        div { class: 'three wide inline field' }, [
          input
            type: 'checkbox'
            id: 'authorizations-photos'
            name: 'authorizations-photos'
            checked: auth.photos
            change: (e) ->
              auth.photos = e.target.checked
              props.member.authorizations.set auth
          label { for: 'authorizations-photos' }
          , L 'AUTHORIZATIONS_PHOTOS'
        ]
      ]
      props

`note` optional long text description.

    mform.views.fields.note = (props) ->
      props.$dom = div { class:'field' }, [
        label { for: 'note' }, L 'NOTE'
        textarea
          name: 'note'
          value: props.member.note.get()
          change: (e) -> props.member.note.set e.target.value
        , props.member.note.get()
        ]
      props

#### Composable views

`civility` contains all fields around the member's civility.

    mform.views.civility = (props) ->
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

`contactDetails` contains all fields related to the member details.

    mform.views.contactDetails = (props) ->
      vf = mform.views.fields
      props.$dom = div [
        h3
          class: 'ui inverted center aligned teal header',
          L 'CONTACT_DETAILS'
        div { class: 'three fields' }, [
          vf.address(props).$dom
          vf.postalCode(props).$dom
          vf.city(props).$dom
        ]
        div { class: 'three fields' }, vf.communicationModes(props).$dom
      ]
      props

`minor` contains all fields for the minor member.

    mform.views.minor = (props) ->
      vf = mform.views.fields
      props.$dom = div [
        golem.common.widgets.headerExpandable
          class: 'inverted center aligned green'
          title: L 'MINOR'
          active: props.minorExpanded
        div { class: 'fields' }, bind ->
          if props.minorExpanded.get()
            _.flatten [
              vf.guardianLastname(props).$dom
              vf.guardianFirstname(props).$dom
              vf.authorizations(props).$dom
            ]
          else
            ''
      ]
      props

`complementary` are extra fields for improving member qualification.

    mform.views.complementary = (props) ->
      props.$dom = div [
        h3
          class: 'ui inverted center aligned blue header',
          L 'COMPLEMENTARY'
        div { class: 'field' }, [mform.views.fields.note(props).$dom]
      ]
      props

`sections` represents all sections of the form.

    mform.views.sections = (props) ->
      props.$dom = [
        h2 title
        mform.views.civility(props).$dom
        mform.views.contactDetails(props).$dom
        mform.views.minor(props).$dom
        mform.views.complementary(props).$dom
        gcform.views.sendInput(props.add)
        gcform.views.cancelButton(null, ->
          window.location.hash = '#/member')
      ]
      props

`form` represents the whole form for adding or editing a member.

    mform.views.form = (props) ->
      props.$dom = form
        id: 'member-form'
        class: 'ui small form'
        submit: mform.submit,
        props.$dom
      props

`sidebar` defines the contextual content. Here are only fixed position button
for sending and cancelling the form. Usefull for finding these buttons easily.

    mform.views.sidebar = (props) ->
      props.$dom = menu { class: 'ui buttons fixed-right' }, [
        gcform.views.sendInput(props.add, 'fluid')
        gcform.views.cancelButton('fluid', ->
          window.location.hash = '#/member')
      ]
      props


`layout` represents the whole DOM of the page, inclufing the form, the sidebar
and some DOM around.

    mform.views.layout = (props) ->
      title = do ->
        if props.add
          L('MEMBERS_NEW')
        else
          "#{L('EDITION_OF')} #{props.member.fullname.get()}"
      props.$dom = [
        section { class: 'twelve wide column' }, [
          golem.menus.secondary
          section { class: 'ui piled segment' }, [
            props.$dom
          ]
        ]
        section { class: 'four wide column' }, [
          mform.views.sidebar(props).$dom
        ]
      ]
      props

## Components

    mform.components = {}

`form` is the unique component of this page, composing all views and passing to
them the `props` objects, updated to add mandatory functions in our situation.

    mform.components.form = (props) ->
      window.gProps = props
      v = mform.views
      _.compose(v.layout, v.form, v.sections)(props)

## Public API

    ns.form = mform
