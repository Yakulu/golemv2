module = golem.module.member
wform = golem.widgets.form
module.component.form =
  controller: ->
    l = golem.config.locale
    mi = module.data.menuItems
    golem.menus.secondary.items = [mi.list, mi.add]
    window.ctrl = @
    m.startComputation()
    newMember = =>
      @add = true
      @member = new golem.Member()

    initController = =>
      if @member.activities.length is 0
        @selectedActivities = []
      else
        @selectedActivities = @activities.filter (a) =>
          @member.activities.indexOf(a._id) isnt -1
        @selectedActivities = @selectedActivities.map (a) -> a.fullLabel()
      @minorExpanded = false
      @telsWidget = golem.component.form.telsWidget module, @member
      @mailsWidget = golem.component.form.mailsWidget module, @member
      @tagWidget = golem.component.form.tagWidget module, @member.tags
      @skillWidget = new golem.widgets.form.tagWidget.controller
        name: 'skills'
        label: l.SKILLS
        placeholder: l.SKILLS_NEW
        content: l.INFO_FORM_SKILLS
        size: 25
        tags: module.data.skills.map (skill) -> skill.key[1]
        current: @member.skills
      #@activitiesWidget = new golem.widgets.form.multiFieldWidget.controller({
      #          tagName: 'select',
      #          label: l.ACTIVITIES_CHOICE,
      #          name: 'activities',
      #          content: l.INFO_FORM_ACTIVITIES,
      #          current: @member.activities
      #        });
      if @add
        document.title = golem.utils.title l.MEMBERS_NEW
      else
        document.title = golem.utils.title l.EDITION_OF + @member.fullname()
        ['show', 'edit', 'remove'].forEach (v) =>
          mi[v].url = mi[v].baseUrl + '/' + @member._id
        golem.menus.secondary.items.splice 2, 0, mi.show, mi.edit, mi.remove
      @familyFromMember = m.prop true # TMP : avoiding family form
      m.endComputation()

    key = m.route.param 'memberId'
    # TMP: Family OFF
    #      @familyFromMember = m.prop(false);
    #      @affectFamily = m.prop(false);
    #      @family = m.prop(null);
    #      @getFamilies = function () {
    #        @affectFamily(true);
    #        @familyList = new golem.module.family.component.list.controller(true, me);
    #        m.startComputation();
    #        golem.model.db.query(
    #          'all/bySchema',
    #          {
    #            startkey: ['family'],
    #            endkey: ['family', {}],
    #            include_docs: true
    #          }, function (err, res) {
    #            @families = res.rows;
    #            m.endComputation();
    #          }
    #        );
    #      };
    main = =>
      unless key
        newMember()
        initController()
      else
        golem.model.db.get key, (err, res) =>
          if err
            golem.widgets.common.notifications.warning body: l.ERROR_RECORD_NOT_FOUND
            m.route '/member/list'
            m.endComputation()
          else
            @member = new golem.Member res
            initController()
            #@familyFromMember(false);

    golem.model.getBySchema 'activity', (err, res) =>
      if err
        @activities = []
        golem.widgets.common.notifications.errorUnexpected body: err
      else
        @activities = res.rows.map (r) -> new golem.Activity r.doc
      golem.model.getLabels('tels',
        golem.model.getLabels.bind(this, 'mails',
          module.data.getTags.bind(this,
            module.data.getSkills.bind(this, main))))

    @submit = golem.component.form.submit.bind this, 'member'
    return

  view: (ctrl) ->
    l = golem.config.locale
    f = ctrl.member
    form = golem.widgets.form
    h2 = (if ctrl.add then l.MEMBERS_NEW else "#{l.EDITION_OF} #{f.fullname()}")
    activitiesList = do ->
      content = if f.activities.length is 0 then l.NONE_F else ctrl.selectedActivities.join ', '
      m 'span', content
    initialContent = m 'section', { class: 'ui piled segment' }, [
      m 'p', l.MEMBERS_NEW_FAMILY_MSG
      m 'button',
        class: 'fluid ui button'
        onclick: ctrl.getFamilies,
        l.MEMBERS_NEW_FAMILY_AFFECT
      m 'button',
        class: 'fluid ui button'
        onclick: -> m.route '/family/add',
        l.MEMBERS_NEW_FAMILY_NEW
      m 'button',
        class: 'fluid ui button'
        onclick: ctrl.familyFromMember.bind(ctrl, true),
        l.MEMBERS_NEW_FAMILY_FROM
    ]
    familyDom = (f) ->
      m 'option', { value: f._id }, f.lastname + f.fulladdress()

    familyContent = ->
      m 'section', { class: 'ui piled segment' }, [
        m 'h2', l.MEMBERS_NEW_FAMILY_AFFECT
        m 'div', { class: 'ui grid' }, [
          new golem.module.family.component.list.view ctrl.familyList
        ]
      ]

    formContent = m 'section', { class: 'ui piled segment' }, [
      m 'h2', h2
      m 'form',
        id: 'member-form'
        class: 'ui small form'
        onsubmit: ctrl.submit.bind(ctrl),
        [
          m 'h3',
            class: 'ui inverted center aligned purple header',
            l.CIVILITY
          m 'div.fields', [
            form.textHelper
              cls: 'four wide field'
              name: 'number'
              label: l.MEMBER_NUMBER
              minlength: 1
              maxlength: 20
              value: f.number
              onchange: m.withAttr 'value', (v) -> f.number = v
            form.textHelper
              cls: 'six wide field'
              name: 'lastname'
              label: l.LASTNAME
              minlength: 2
              maxlength: 100
              required: true
              value: f.lastname
              validationMsg: l.LASTNAME_VALIDATION_MSG
              validationCallback: (e) -> f.lastname = e.target.value
            form.textHelper
              cls: 'six wide field'
              name: 'firstname'
              label: l.FIRSTNAME
              minlength: 2
              maxlength: 100
              required: true
              value: f.firstname
              validationMsg: l.LASTNAME_VALIDATION_MSG
              validationCallback: (e) -> f.firstname = e.target.value
          ]
          m 'div.fields', [
            m 'div', { class: 'one wide field' }, l.GENDER
            m 'div', { class: 'two wide field' }, [
              m 'div', { class: 'ui radio checkbox' }, [
                m 'input',
                  type: 'radio'
                  name: 'gender'
                  value: 'm'
                  checked: (f.gender is 'm')
                  onchange: (v) -> f.gender = 'm'
                m 'label', { onclick: (v) -> f.gender = 'm' }, l.GENDER_MALE
              ]
            ]
            m 'div', { class: 'two wide field' }, [
              m 'div', { class: 'ui radio checkbox' }, [
                m 'input',
                  type: 'radio'
                  name: 'gender'
                  value: 'f'
                  checked: (f.gender is 'f')
                  onchange: (v) -> f.gender = 'f'
                m 'label', { onclick: (v) -> f.gender = 'f' }, l.GENDER_FEMALE
              ]
            ]
            form.textHelper
              cls: 'three wide field'
              name: 'birthday'
              label: l.BIRTHDAY
              placeholder: l.BIRTHDAY_PLACEHOLDER
              pattern: '\\d{2}/\\d{2}/\\d{4}'
              value: (if f.birthday then moment(f.birthday).format('L') else '')
              onchange: m.withAttr 'value', (v) ->
                v = golem.component.form.dateFormat v
                if v
                  f.birthday = v.toString()
                  # If the person is minor, expand the fields
                  isMinor = v.isAfter(moment().subtract(18, 'years'))
                  if isMinor
                    ctrl.minorExpanded = true
                    if ctrl.add
                      f.authorizations.activities = true
                      f.authorizations.photos = true
                else
                  f.birthday = null
            form.textHelper
              cls: 'four wide field'
              name: 'nationality'
              label: l.NATIONALITY
              value: f.nationality
              onchange: m.withAttr 'value', (v) -> f.nationality = v
            form.textHelper
              cls: 'four wide field'
              name: 'profession'
              label: l.PROFESSION
              value: f.profession
              onchange: m.withAttr 'value', (v) -> f.profession = v
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
                name: 'cmodes-mail'
                checked: f.communicationModes['mail']
                onchange: m.withAttr 'checked', (c) -> f.communicationModes['mail'] = c
              m 'label', { for: 'cmodes-mail' }, l.MAIL
            ]
            m 'div', { class: 'inline field' }, [
              m 'input',
                type: 'checkbox'
                name: 'cmodes-tel'
                checked: f.communicationModes['tel']
                onchange: m.withAttr 'checked', (c) -> f.communicationModes['tel'] = c
              m 'label', { for: 'cmodes-tel' }, l.TEL
            ]
          ]
          golem.widgets.common.headerExpandible
            ctrl: ctrl
            activeField: 'minorExpanded'
            title: l.MINOR
            cls: 'inverted center aligned green'
          m 'div',
            class: 'fields'
            style: { display: (if ctrl.minorExpanded then 'block' else 'none') }, [
              m 'div', { class: 'two wide field' }, l.CHILD_GUARDIAN
              form.textHelper
                cls: 'three wide field'
                name: 'guardian-lastname'
                label: l.LASTNAME
                minlength: 2
                maxlength: 100
                value: f.guardianLastname
                onchange: m.withAttr 'value', (v) -> f.guardianLastname = v
              form.textHelper
                cls: 'three wide field'
                name: 'guardian-firstname'
                label: l.FIRSTNAME
                minlength: 2
                maxlength: 100
                value: f.guardianFirstname
                onchange: m.withAttr 'value', (v) -> f.guardianFirstname = v
              m 'div', { class: 'two wide field' }, l.AUTHORIZATIONS
              m 'div', { class: 'three wide inline field' }, [
                m 'input',
                  type: 'checkbox'
                  name: 'authorizations-activities'
                  checked: f.authorizations['activities']
                  onchange: m.withAttr 'checked', (c) -> f.authorizations['activities'] = c
                m 'label', { for: 'authorizations-activities' }, l.ACTIVITIES_PARTICIPATION
              ]
              m 'div', { class: 'three wide inline field' }, [
                m 'input',
                  type: 'checkbox'
                  name: 'authorizations-photos'
                  checked: f.authorizations['photos']
                  onchange: m.withAttr 'checked', (c) -> f.authorizations['photos'] = c
                m 'label', { for: 'authorizations-photos' }, l.AUTHORIZATIONS_PHOTOS
              ]
          ]
          m 'h3',
            class: 'ui inverted center aligned blue header',
            l.COMPLEMENTARY
          m 'div', { class: 'two fields' }, [
            #new form.multiFieldWidget.view(ctrl.wwwWidget),
            new form.tagWidget.view ctrl.tagWidget
            new form.tagWidget.view ctrl.skillWidget
          ]
          m 'div.field', [
            m 'label', { for: 'note' }, l.NOTE
            m 'textarea',
              name: 'note'
              value: f.note
              onchange: m.withAttr('value', (v) -> f.note = v),
              f.note
          ]
          m 'h3', { class: 'ui inverted center aligned red header' }, l.ACTIVITIES
          m 'div', { class: 'ui grid' }, [
            m 'div', { class: 'eight wide column' }, [
              m 'div.field', [
                # TODO : multiFieldWidget refactoring to allow select and others...
                m 'select',
                  name: 'activities'
                  multiple: true
                  size: ctrl.activities.length + 1
                  onchange: (e) ->
                    selectedActivities = []
                    ctrl.selectedActivities = []
                    for option in e.target.options
                      if option.selected
                        selectedActivities.push option.value
                        ctrl.selectedActivities.push option.text
                    f.activities = selectedActivities
                  , [
                      m 'optgroup', { label: l.ACTIVITIES }, ctrl.activities.map (a) ->
                        m 'option',
                          value: a._id
                          label: a.fullLabel()
                          selected: (a._id in f.activities),
                          a.fullLabel()
                    ]
                m 'p', [
                  m 'span', l.ACTIVITIES_SELECTED
                  activitiesList
                ]
              ]
            ]
            m 'div', { class: 'eight wide column' }, [
              m 'div', { class: 'ui purple inverted segment' }, [
                m 'h3', [
                  m 'i', { class: 'info icon' }
                  m 'span', l.HELP
                ]
                m 'p', m.trust l.ACTIVITIES_HELP
              ]
            ]
          ]
          m 'input',
            id: 'member-submit'
            class: 'ui teal submit button'
            type: 'submit'
            form: 'member-form'
            value: (if ctrl.add then l.SAVE else l.UPDATE)
            # FIXME : here's a hack, to fix properly
          m 'button',
            name: 'cancel'
            class: 'ui button'
            type: 'button'
            onclick: -> m.route '/member/list'
            l.CANCEL
      ]
    ]
    contextMenuContent = m 'nav', [
      m 'menu', { class: 'ui buttons fixed-right' }, [
        m 'input',
          class: 'ui fluid teal submit button'
          type: 'submit'
          value: (if ctrl.add then l.SAVE else l.UPDATE)
          onclick: -> document.getElementById('member-submit').click()
        m 'div',
          role: 'button'
          class: 'ui fluid button'
          onclick: -> m.route '/member/list'
        , l.CANCEL
      ]
    ]
    # Form if editing, if family will be created form members details or
    # if a family has already been affected
    isForm = (not ctrl.add or ctrl.familyFromMember() or !!ctrl.family())
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
