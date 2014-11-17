module = golem.module.member
module.component.list =
  controller: ->
    l = golem.config.locale
    mi = module.data.menuItems
    gcl = golem.component.list
    gwf = golem.widgets.form
    golem.menus.secondary.items = [mi.list, mi.add, mi.tags, mi.skills]
    document.title = golem.utils.title l.MEMBERS_LIST
    @sort = (e) => golem.component.list.sort e, @items
    @searchGlobal = (e) =>
      value = e.target.value
      if value.length > 3
        @activeFilters.search = gcl.search.bind null, value
      else
        delete @activeFilters.search
      gcl.filter @

    
    @searchHelp = new gwf.helpButton.controller l.HELP, l.SEARCH_ADVANCED_EXTENDED_HELP
    @searchCounter = 0
    @searchAdd = =>
      @searchCounter += 1
      @searches.push field: null, value: ''
    @searchRemove = (idx) =>
      s = (@searches.splice idx, 1)[0]
      if @activeFilters[s.name]
        delete @activeFilters[s.name]
        gcl.filter @
    @searchSelect = (idx, e) =>
      s = @searches[idx]
      delete @activeFilters[s.name] if @activeFilters[s.name]
      s.field = e.target.value
      s.name = "#{e.target.value}-#{@searchCounter}"
    @searchBirthdaySelect = (idx, value) =>
      @searches[idx].constraint = value
    @searchValue = (idx, value) => @searches[idx].value = value

    @searchAdvanced = (reset, e) =>
      e.preventDefault()
      @searches.forEach (s, idx) =>
        switch s.field
          when 'lastname', 'firstname', 'nationality', 'profession'
          , 'postalCode', 'city', 'number'
            value = s.value.toLowerCase()
            @activeFilters[s.name] = (item) ->
              return false unless item[s.field]
              item[s.field].toLowerCase().indexOf(value) isnt -1
          when 'fullname', 'fulladdress', 'fullguardian'
            value = s.value.toLowerCase()
            @activeFilters[s.name] = (item) ->
              item[s.field]?().toLowerCase().indexOf(value) isnt -1
          when 'tels', 'mails'
            value = s.value.toLowerCase()
            @activeFilters[s.name] = (item) ->
              for f in item[s.field]
                return true if f.value.toLowerCase().indexOf(value) isnt -1
              false
          when 'communicationModes'
            @activeFilters[s.name] = (item) -> item[s.field][s.value]
          when 'gender'
            @activeFilters[s.name] = (item) -> item[s.field] is s.value
          when 'isMinor'
            @activeFilters[s.name] = (item) -> 
              s.value = false if _(s.value).isString()
              false unless item.birthday
              isMinor = moment(item.birthday).isAfter(moment().subtract(18, 'years'))
              isMinor is s.value
          when 'birthday'
            #@activeFilters[s.field] = (item) ->
            @activeFilters[s.name] = (item) ->
              false unless item.birthday
              switch s.constraint
                when 'equality'
                  moment(item.birthday).format() is s.value.format()
                when 'before'
                  moment(item.birthday).isBefore s.value
                when 'after'
                  moment(item.birthday).isAfter s.value

      gcl.filter @


    @filterByTag = (tag, field) =>
      if tag
        @tagFilter = tag
        @activeFilters.tags = (member) ->
          member[field] and tag in member[field]
      else
        @tagFilter = null
        delete @activeFilters.tags
      gcl.filter @

    @filtersRemoveAll = =>
      @searches = []
      @activeFilters = {}
      @tagFilter = null
      @searchAdvancedOn = false
      gcl.filter @

    @csvExport = =>
      _items = @filteredItems or @items
      items = (_.clone item for item in _items)
      schema =
        number: l.MEMBER_NUMBER
        lastname: l.LASTNAME
        firstname: l.FIRSTNAME
        address: l.ADDRESS
        postalCode: l.POSTAL_CODE
        city: l.CITY
        birthday: l.BIRTHDAY
        gender: l.GENDER
        nationality: l.NATIONALITY
        profession: l.PROFESSION
        mails: l.MAILS
        tels: l.TELS
        communicationModes: l.COMMUNICATION_MODES
        authorizations: l.AUTHORIZATIONS
        guardian: l.CHILD_GUARDIAN
        skills: l.SKILLS
        tags: l.TAGS
      for item in items
        item.guardian = "#{item.guardianLastname} #{item.guardianFirstname}" if item.guardianLastname
        for field, locale of schema
          switch field
            when 'birthday'
              item[field] = if item.birthday then moment(item.birthday).format('L') else ''
            when 'tels', 'mails'
              values = ("#{v.label}: #{v.value}" for v in item[field])
              item[field] = values.join ','
            when 'communicationModes', 'authorizations'
              keys = []
              for k, v of item[field]
                if v then keys.push k
              item[field] = keys.join ','
            else
              item[field] ?= ''
      gcl.csvExport items, schema, 'adherents'

    callback = (err, results) =>
      if err
        golem.widgets.common.notifications.errorUnexpected body: err
        @items = []
      else
        @items = results.rows.map (r) -> new golem.Member r.doc
      m.endComputation()

    # Init
    @items = []
    @filteredItems = null
    @activeFilters = {}
    @searchAdvancedOn = false
    @searches = [] # Arrays of objects representing search form

    m.startComputation()
    module.data.getTags =>
      @tags = module.data.tags[0..4] # Only the first five tags for listing, thx
      module.data.getSkills =>
        @skills = module.data.skills[0..4]
        golem.model.getBySchema 'member', callback
    return

  view: (ctrl) ->
    l = golem.config.locale
    form = golem.widgets.form


    searchExtraFields = (s, idx) ->
      switch s.field
        when 'number', 'lastname', 'firstname', 'fullname', 'nationality'
        , 'profession', 'fulladdress', 'postalCode', 'city', 'tels', 'mails'
        , 'fullguardian'
          [
            m 'input',
              class: 'six wide field input'
              name: "#{s.field}-#{idx}"
              type: 'text'
              required: true
              placeholder: l.TYPE_HERE
              value: s.value
              oninput: m.withAttr 'value', ctrl.searchValue.bind(ctrl, idx)
          ]
        when 'gender'
          [
            m 'div', { class: 'ui radio checkbox' }, [
              m 'input',
                type: 'radio'
                id: "#{s.field}-#{idx}-m"
                name: "#{s.field}-#{idx}"
                value: 'm'
                checked: s.value is 'm'
                onchange: m.withAttr 'value', ctrl.searchValue.bind(ctrl, idx)
              m 'label', { for: "#{s.field}-#{idx}-m" }, l.GENDER_MALE
            ]
            m 'div', { class: 'ui radio checkbox' }, [
              m 'input',
                type: 'radio'
                id: "#{s.field}-#{idx}-f"
                name: "#{s.field}-#{idx}"
                value: 'f'
                checked: (s.value is 'f')
                onchange: m.withAttr 'value', ctrl.searchValue.bind(ctrl, idx)
              m 'label', { for: "#{s.field}-#{idx}-f" }, l.GENDER_FEMALE
            ]
            m 'div', { class: 'ui radio checkbox' }, [
              m 'input',
                type: 'radio'
                id: "#{s.field}-#{idx}-false"
                name: "#{s.field}-#{idx}"
                value: ''
                checked: s.value is ''
                onchange: m.withAttr 'value', ctrl.searchValue.bind(ctrl, idx)
              m 'label', { for: "#{s.field}-#{idx}-false" }, l.NOT_INFORMED
            ]
          ]
        when 'communicationModes'
          [
            m 'div', { class: 'ui radio checkbox' }, [
              m 'input',
                type: 'radio'
                id: "#{s.field}-#{idx}-mail"
                name: "#{s.field}-#{idx}"
                checked: s.value is 'mail'
                value: 'mail'
                onchange: m.withAttr 'value', ctrl.searchValue.bind(ctrl, idx)
              m 'label', { for: "#{s.field}-#{idx}-mail" }, l.MAIL
            ]
            m 'div', { class: 'ui radio checkbox' }, [
              m 'input',
                type: 'radio'
                id: "#{s.field}-#{idx}-tel"
                name: "#{s.field}-#{idx}"
                checked: s.value is 'tel'
                value: 'tel'
                onchange: m.withAttr 'value', ctrl.searchValue.bind(ctrl, idx)
              m 'label', { for: "#{s.field}-#{idx}-tel" }, l.TEL
            ]
          ]
        when 'isMinor'
          [
            m 'input',
              type: 'checkbox'
              name: 'isMinor'
              checked: s.value
              onchange: m.withAttr 'checked', ctrl.searchValue.bind(ctrl, idx)
          ]
        when 'birthday'
          [
            m 'select',
              class: 'three wide field'
              required: true
              onchange: m.withAttr 'value', ctrl.searchBirthdaySelect.bind(ctrl, idx)
            , [
              m 'option', { value: '', hidden: true }
              m 'option', value: 'before', l.BORN_BEFORE
              m 'option', value: 'equality', l.BORN
              m 'option', value: 'after', l.BORN_AFTER
            ]
            m 'input',
              class: 'six wide field input'
              name: "#{s.field}-#{idx}"
              type: 'text'
              required: true
              placeholder: l.BIRTHDAY_PLACEHOLDER
              value: if (_(s.value).isString() is false) then s.value.format 'L' else ''
              onchange: m.withAttr 'value', (v) ->
                v = golem.component.form.dateFormat v
                v ?= ''
                ctrl.searchValue idx, v
          ]
        else []

    advancedSearchDom = ->
      m 'form',
        class: 'ui small form'
        onsubmit: ctrl.searchAdvanced.bind(ctrl, false),
        [
          m 'fieldset.fields', [
            m 'legend', l.FILTERS
            m 'div', { class: 'ui buttons' }, [
              new golem.widgets.form.helpButton.view ctrl.searchHelp
              form.addButton ctrl.searchAdd, l.NEW
            ]
            ctrl.searches.map (s, idx) ->
              m 'div', { class: 'fields' }, [
                m 'select',
                  onchange: ctrl.searchSelect.bind(ctrl, idx)
                  value: s.field
                  class: 'five wide field'
                  required: true
                  'data-idx': idx
                  name: "search-adv-#{idx}", [
                    m 'option', { value: '', hidden: true }
                    m 'optgroup', label: l.CIVILITY, [
                      m 'option', value: 'number', l.MEMBER_NUMBER
                      m 'option', value: 'lastname', l.LASTNAME
                      m 'option', value: 'firstname', l.FIRSTNAME
                      m 'option', value: 'fullname', l.FULLNAME
                      m 'option', value: 'gender', l.GENDER
                      m 'option', value: 'birthday', l.BIRTHDAY
                      m 'option', value: 'nationality', l.NATIONALITY
                      m 'option', value: 'profession', l.PROFESSION
                    ]
                    m 'optgroup', label: l.CONTACT_DETAILS, [
                      m 'option', value: 'fulladdress', l.FULLADDRESS
                      m 'option', value: 'postalCode', l.POSTAL_CODE
                      m 'option', value: 'city', l.CITY
                      m 'option', value: 'tels', l.TEL
                      m 'option', value: 'mails', l.MAIL
                      m 'option',
                        value: 'communicationModes',
                        l.COMMUNICATION_MODES
                    ]
                    m 'optgroup', label: l.MINOR, [
                      m 'option', value: 'isMinor', l.MINOR_IS
                      m 'option', value: 'fullguardian', l.CHILD_GUARDIAN
                      m 'option', value: 'authorizations', l.AUTHORIZATIONS
                    ]
                  ]
                searchExtraFields(s, idx).map (xfield) -> xfield
                m 'button', # Remove button
                  type: 'button'
                  class: 'ui small red icon button'
                  title: l.DELETE
                  onclick: (e) -> ctrl.searchRemove idx
                , [ m 'i', { class: 'remove sign icon' } ]
              ]
            m 'p', [
              m 'input',
                class: 'ui teal tiny submit button'
                type: 'submit'
                value: l.SEARCH
            ]
          ]
        ]

    itemDom = (f) ->
      m 'tr', [
        m 'td', f.number
        m 'td', f.fullname()
        #m('td', f.family),
        m 'td', f.fulladdress()
        m 'td', f.tels.forEach (t) ->
          if t.default
            t.value.match(/\d{2}/g).join '.'
        m 'td', f.mails.map (mail) ->
          if mail.default
            m 'a', { href: 'mailto:' + mail.value }, mail.value
        m 'td.actions', [
          m 'a',
            href: '#/member/show/' + f._id
            title: l.VIEW,
            [m 'i', { class: 'unhide icon' }]
          m 'a',
            href: '#/member/edit/' + f._id
            title: l.EDIT,
            [m 'i', { class: 'edit icon' }]
          m 'a',
            href: '#/member/remove/' + f._id
            title: l.DELETE
            [m 'i', { class: 'remove icon' }]
        ]
      ]

    items = ctrl.filteredItems or ctrl.items
    gcl = golem.component.list
    mainContent = m 'section', { class: 'twelve wide column' }, [
      m 'table', { class: 'ui basic table' }, [
        m 'thead', [
          m 'tr', [
            gcl.sortTableHeaderHelper
              ctrl: ctrl
              field: 'number'
              title: 'MEMBER_NUMBER'
            gcl.sortTableHeaderHelper ctrl: ctrl, field: 'lastname'
            gcl.sortTableHeaderHelper
              ctrl: ctrl
              field: 'city'
              title: 'ADDRESS'
            # m('th', l.FAMILY),
            m 'th', [
              m 'span', l.TEL
              m 'i', { class: 'icon info', title: l.DEFAULT_ONLY }
            ]
            m 'th', [
              m 'span', l.MAIL
              m 'i', { class: 'icon info', title: l.DEFAULT_ONLY }
            ]
            m 'th', { width: '10%' }, l.ACTIONS
          ]
        ]
        m 'tbody', items.map itemDom
      ]
    ]
    tagsBox = golem.component.list.tagsBox { tags: ctrl.tags }, ctrl
    skillsBox = golem.component.list.tagsBox
      field: 'skills'
      label: l.BY_SKILL
      tagsIcon: 'briefcase'
      counterCls: 'blue',
      ctrl
    contextMenuContent = m 'section', { class: 'four wide column' },
      m 'nav', [
        m 'menu', { class: 'ui small vertical menu' }, [
          tagsBox.head
          tagsBox.tags
          skillsBox.tags
        ]
      ]
    listHeaderDom = do ->
      titleDom = [ l.MEMBERS_LIST + ' ' ]
      unless _(ctrl.activeFilters).isEmpty()
        titleDom.push m 'i'
      m 'h3',
        class: 'ui inverted center aligned purple header',
        [ m 'span', titleDom ]

    eraserVisibility = do ->
      if _(ctrl.activeFilters).isEmpty() then 'hidden' else 'visible'

    return [
      m 'section', { class: 'twelve wide column golem-list' }, [
        new golem.menus.secondary.view()
        golem.widgets.common.headerExpandible
          ctrl: ctrl
          activeField: 'searchAdvancedOn'
          title: l.SEARCH_ADVANCED
          cls: 'inverted center aligned black'
        advancedSearchDom() if ctrl.searchAdvancedOn
        m 'h3',
          class: 'ui inverted center aligned purple header',
          [
            m 'span', [
              l.MEMBERS_LIST + ' '
              m 'a',
                title: l.MAILING
                style: display: 'inline'
                href: golem.component.list.mailing items
                [ m 'i', class: 'mail outline icon' ]
              m 'i',
                title: l.CSV_EXPORT
                class: 'text file outline icon'
                style: cursor: 'pointer', display: 'inline'
                onclick: ctrl.csvExport
              m 'i',
                title: l.FILTERS_REMOVE
                class: 'icon eraser'
                style:
                  cursor: 'pointer'
                  visibility: eraserVisibility
                  display: 'inline'
                onclick: ctrl.filtersRemoveAll
          ]
        ]
        mainContent
      ]
      m 'section', { class: 'four wide column' }, contextMenuContent
    ]
