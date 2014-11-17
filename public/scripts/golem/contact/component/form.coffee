module = golem.module.contact
wform = golem.widgets.form
module.component.form =
  controller: ->
    l = golem.config.locale
    mi = module.data.menuItems
    golem.menus.secondary.items = [mi.list, mi.add]
    m.startComputation()
    newContact = =>
      @add = true
      @contact = new golem.Contact()

    initController = =>
      @telsWidget = golem.component.form.telsWidget module, @contact
      @mailsWidget = golem.component.form.mailsWidget module, @contact
      @tagWidget = golem.component.form.tagWidget module, @contact.tags
      if @add
        document.title = golem.utils.title l.CONTACTS_NEW
      else
        document.title = golem.utils.title l.EDITION_OF + @contact.fullname()
        ['show', 'edit', 'remove'].forEach (v) =>
          mi[v].url = mi[v].baseUrl + '/' + @contact._id
        golem.menus.secondary.items.splice 2, 0, mi.show, mi.edit, mi.remove
      @familyFromContact = m.prop true # TMP : avoiding family form
      m.endComputation()

    key = m.route.param 'contactId'
    main = =>
      unless key
        newContact()
        initController()
      else
        golem.model.db.get key, (err, res) =>
          if err
            golem.widgets.common.notifications.warning body: l.ERROR_RECORD_NOT_FOUND
            m.route '/contact/list'
            m.endComputation()
          else
            @contact = new golem.Contact res
            initController()

    golem.model.getLabels('tels',
      golem.model.getLabels.bind(this, 'mails',
        module.data.getTags.bind(this, main)))

    @submit = golem.component.form.submit.bind this, 'contact'
    return

  view: (ctrl) ->
    l = golem.config.locale
    f = ctrl.contact
    form = golem.widgets.form
    h2 = (if ctrl.add then l.CONTACTS_NEW else "#{l.EDITION_OF} #{f.fullname()}")
    formContent = m 'section', { class: 'ui piled segment' }, [
      m 'h2', h2
      m 'form',
        id: 'contact-form'
        class: 'ui small form'
        onsubmit: ctrl.submit.bind(ctrl),
        [
          m 'h3',
            class: 'ui inverted center aligned purple header',
            l.CIVILITY
          m 'div.fields', [
            form.textHelper
              cls: 'eight wide field'
              name: 'lastname'
              label: l.LASTNAME
              minlength: 2
              maxlength: 100
              required: true
              value: f.lastname
              validationMsg: l.LASTNAME_VALIDATION_MSG
              validationCallback: (e) -> f.lastname = e.target.value
            form.textHelper
              cls: 'eight wide field'
              name: 'firstname'
              label: l.FIRSTNAME
              minlength: 2
              maxlength: 100
              required: true
              value: f.firstname
              validationMsg: l.LASTNAME_VALIDATION_MSG
              validationCallback: (e) -> f.firstname = e.target.value
          ]
          m 'h3',
            class: 'ui inverted center aligned teal header',
            l.CONTACT_DETAILS
          m 'div',
            class: 'three fields',
            [
              form.textHelper
                name: 'address'
                label: l.ADDRESS
                value: f.address
                onchange: m.withAttr 'value', (v) -> f.address = v
              form.textHelper
                name: 'postalCode'
                label: l.POSTAL_CODE
                value: f.postalCode
                maxlength: 5
                pattern: '^\\d{5}$'
                validationMsg: l.POSTAL_CODE_VALIDATION_MSG
                validationCallback: (e) -> f.postalCode = e.target.value
              form.textHelper
                name: 'city'
                label: l.CITY
                value: f.city
                onchange: m.withAttr 'value', (v) -> f.city = v
            ]
          m 'div', { class: 'ui two fields' }, [
            m 'div.field', [new form.multiFieldWidget.view ctrl.telsWidget]
            m 'div.field', [new form.multiFieldWidget.view ctrl.mailsWidget]
          ]
          m 'div', { class: 'three fields' }, [
            m 'div.field', l.COMMUNICATION_MODES
            m 'div', { class: 'inline field' }, [
              m 'input',
                type: 'checkbox'
                id: 'cmodes-mail'
                name: 'cmodes-mail'
                checked: f.communicationModes['mail']
                onchange: m.withAttr 'checked', (c) -> f.communicationModes['mail'] = c
              m 'label', { for: 'cmodes-mail' }, l.MAIL
            ]
            m 'div', { class: 'inline field' }, [
              m 'input',
                type: 'checkbox'
                id: 'cmodes-tel'
                name: 'cmodes-tel'
                checked: f.communicationModes['tel']
                onchange: m.withAttr 'checked', (c) -> f.communicationModes['tel'] = c
              m 'label', { for: 'cmodes-tel' }, l.TEL
            ]
          ]
          m 'h3',
            class: 'ui inverted center aligned blue header',
            l.COMPLEMENTARY
          m 'div', { class: 'field' }, [
            #new form.multiFieldWidget.view(ctrl.wwwWidget),
            new form.tagWidget.view ctrl.tagWidget
          ]
          m 'div.field', [
            m 'label', { for: 'note' }, l.NOTE
            m 'textarea',
              name: 'note'
              value: f.note
              onchange: m.withAttr('value', (v) -> f.note = v),
              f.note
          ]
          m 'input',
            id: 'contact-submit'
            class: 'ui teal submit button'
            type: 'submit'
            form: 'contact-form'
            value: (if ctrl.add then l.SAVE else l.UPDATE)
            # FIXME : here's a hack, to fix properly
          m 'button',
            name: 'cancel'
            class: 'ui button'
            type: 'button'
            onclick: -> m.route '/contact/list'
            l.CANCEL
      ]
    ]
    contextMenuContent = m 'nav', [
      m 'menu', { class: 'ui buttons fixed-right' }, [
        m 'input',
          class: 'ui fluid teal submit button'
          type: 'submit'
          value: (if ctrl.add then l.SAVE else l.UPDATE)
          onclick: -> document.getElementById('contact-submit').click()
        m 'div',
          role: 'button'
          class: 'ui fluid button'
          onclick: -> m.route '/contact/list'
        , l.CANCEL
      ]
    ]
    # Form if editing, if family will be created form contacts details or
    # if a family has already been affected
    isForm = (not ctrl.add or ctrl.familyFromContact() or !!ctrl.family())
    if isForm
      mainContent = formContent
    else
      if ctrl.affectFamily()
        # We have to select and affect a family
        mainContent = familyContent()
      else
        # Home choice
        mainContent = initialContent
    return [
      m 'section', { class: 'twelve wide column' }, [
        new golem.menus.secondary.view()
        mainContent
      ]
      m 'section', { class: 'four wide column' }, (if isForm then contextMenuContent else '')
    ]
